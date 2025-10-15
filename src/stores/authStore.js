import { defineStore } from 'pinia'
import { supabase } from '../config/supabase'

export const useAuthStore = defineStore('auth', {
  state: () => ({
    user: null,
    profile: null,
    session: null,
    loading: false,
    error: null
  }),

  getters: {
    isAuthenticated: (state) => !!state.user,
    isAdmin: (state) => state.profile?.role === 'admin',
    isPlayer: (state) => state.profile?.role === 'player',
    userRole: (state) => state.profile?.role,
    userEmail: (state) => state.user?.email,
    userName: (state) => state.profile?.full_name || state.user?.email
  },

  actions: {
    async initialize() {
      // Get initial session
      const { data: { session } } = await supabase.auth.getSession()
      
      if (session) {
        this.session = session
        this.user = session.user
        await this.fetchProfile()
        
        // Check if user account is active
        if (this.profile && this.profile.is_active === false) {
          // Sign out immediately if account is deactivated
          await supabase.auth.signOut()
          this.session = null
          this.user = null
          this.profile = null
          this.error = 'Your account has been deactivated. Please contact staff for assistance.'
        }
      }

      // Listen for auth changes
      supabase.auth.onAuthStateChange(async (event, session) => {
        this.session = session
        this.user = session?.user || null
        
        if (session?.user) {
          await this.fetchProfile()
          
          // Check if user account is active
          if (this.profile && this.profile.is_active === false) {
            // Sign out immediately if account is deactivated
            await supabase.auth.signOut()
            this.session = null
            this.user = null
            this.profile = null
            this.error = 'Your account has been deactivated. Please contact staff for assistance.'
          }
        } else {
          this.profile = null
        }
      })
    },

    async fetchProfile() {
      if (!this.user) return

      try {
        const { data, error } = await supabase
          .from('users')
          .select('*')
          .eq('auth_id', this.user.id)
          .maybeSingle()  // Use maybeSingle to avoid errors if no profile found

        if (error) throw error
        
        // If no profile found, user might be new - profile will be created by trigger
        this.profile = data || null
      } catch (err) {
        console.error('Error fetching profile:', err)
        this.error = err.message
        this.profile = null
      }
    },

    async signUp({ email, password, fullName, role = 'player' }) {
      this.loading = true
      this.error = null

      try {
        // First check if user already exists in our users table
        const { data: existingUser } = await supabase
          .from('users')
          .select('email')
          .eq('email', email)
          .single()

        if (existingUser) {
          throw new Error('This email is already registered. Please use a different email or try logging in.')
        }

        const { data, error } = await supabase.auth.signUp({
          email,
          password,
          options: {
            data: {
              full_name: fullName,
              role: role
            }
          }
        })

        if (error) {
          // Handle specific error cases
          if (error.message.includes('already registered') || error.message.includes('already exists') || error.message.includes('User already registered')) {
            // Check if this is an orphaned Auth user (exists in Auth but not in users table)
            console.log('Auth user exists, checking if orphaned...')
            
            // Try to clean up orphaned Auth user by attempting to sign in and then delete
            try {
              const { data: signInData, error: signInError } = await supabase.auth.signInWithPassword({
                email,
                password: 'dummy_password_to_check' // This will fail but help us identify the user
              })
              
              // If we reach here, the user exists in Auth but with different password
              // This means it's an orphaned Auth user
              throw new Error('This email exists in our system but appears to be orphaned. Please contact support to resolve this issue, or try using a different email address.')
            } catch (signInErr) {
              // User exists in Auth but password is wrong, or user doesn't exist
              if (signInErr.message.includes('Invalid login credentials')) {
                throw new Error('This email is already registered in our system. If you believe this is an error, please contact support or try using a different email address.')
              }
              throw new Error('This email is already registered. Please use a different email or try logging in.')
            }
          }
          throw error
        }

        // Check if user was actually created (not just returning existing user)
        if (data.user && data.user.identities && data.user.identities.length === 0) {
          throw new Error('This email is already registered. Please check your inbox for the confirmation email or try logging in.')
        }

        // Profile will be created automatically by trigger
        return { success: true, data }
      } catch (err) {
        this.error = err.message
        console.error('Sign up error:', err)
        return { success: false, error: err.message }
      } finally {
        this.loading = false
      }
    },

    async signIn({ email, password }) {
      this.loading = true
      this.error = null

      try {
        console.log('authStore: Starting sign in...')
        
        // Add timeout wrapper
        const signInPromise = supabase.auth.signInWithPassword({
          email,
          password
        })
        
        const timeoutPromise = new Promise((_, reject) => 
          setTimeout(() => reject(new Error('Sign in timeout after 10 seconds')), 10000)
        )
        
        const { data, error } = await Promise.race([signInPromise, timeoutPromise])
        console.log('authStore: Sign in response:', { error: !!error })

        if (error) throw error

        this.session = data.session
        this.user = data.user
        await this.fetchProfile()

        // Check if user account is active
        if (this.profile && this.profile.is_active === false) {
          // Sign out immediately if account is deactivated
          await supabase.auth.signOut()
          this.session = null
          this.user = null
          this.profile = null
          throw new Error('Your account has been deactivated. Please contact staff for assistance.')
        }

        console.log('authStore: Sign in successful')
        return { success: true, data }
      } catch (err) {
        this.error = err.message
        console.error('authStore: Sign in error:', err)
        return { success: false, error: err.message }
      } finally {
        this.loading = false
      }
    },

    async signOut() {
      this.loading = true
      this.error = null

      try {
        console.log('authStore: Starting sign out...')
        
        // Add timeout wrapper
        const signOutPromise = supabase.auth.signOut()
        const timeoutPromise = new Promise((_, reject) => 
          setTimeout(() => reject(new Error('Sign out timeout after 5 seconds')), 5000)
        )
        
        const { error } = await Promise.race([signOutPromise, timeoutPromise])
        console.log('authStore: Sign out response:', { error })
        
        if (error) throw error

        this.user = null
        this.profile = null
        this.session = null

        console.log('authStore: Sign out successful')
        return { success: true }
      } catch (err) {
        this.error = err.message
        console.error('authStore: Sign out error:', err)
        
        // Even if error, clear local state
        this.user = null
        this.profile = null
        this.session = null
        
        return { success: false, error: err.message }
      } finally {
        this.loading = false
      }
    },

    async updateProfile(updates) {
      if (!this.user) {
        return { success: false, error: 'Not authenticated' }
      }

      this.loading = true
      this.error = null

      try {
        const { data, error } = await supabase
          .from('users')
          .update(updates)
          .eq('id', this.user.id)
          .select()
          .single()

        if (error) throw error

        this.profile = data
        return { success: true, data }
      } catch (err) {
        this.error = err.message
        console.error('Update profile error:', err)
        return { success: false, error: err.message }
      } finally {
        this.loading = false
      }
    },

    async resetPassword(email) {
      this.loading = true
      this.error = null

      try {
        const { error } = await supabase.auth.resetPasswordForEmail(email, {
          redirectTo: `${window.location.origin}/reset-password`
        })

        if (error) throw error

        return { success: true }
      } catch (err) {
        this.error = err.message
        console.error('Reset password error:', err)
        return { success: false, error: err.message }
      } finally {
        this.loading = false
      }
    },

    async updatePassword(newPassword) {
      this.loading = true
      this.error = null

      try {
        console.log('authStore: Starting password update...')
        
        // Add timeout wrapper
        const updatePromise = supabase.auth.updateUser({
          password: newPassword
        })
        
        const timeoutPromise = new Promise((_, reject) => 
          setTimeout(() => reject(new Error('Supabase API timeout after 8 seconds')), 8000)
        )
        
        const { error, data } = await Promise.race([updatePromise, timeoutPromise])
        console.log('authStore: Update response:', { error, data })

        if (error) throw error

        console.log('authStore: Password updated successfully')
        return { success: true }
      } catch (err) {
        this.error = err.message
        console.error('authStore: Update password error:', err)
        return { success: false, error: err.message }
      } finally {
        this.loading = false
      }
    },

    // Admin functions
    async getAllUsers() {
      if (!this.isAdmin) {
        return { success: false, error: 'Unauthorized' }
      }

      try {
        const { data, error } = await supabase
          .from('users')
          .select('*')
          .order('created_at', { ascending: false })

        if (error) throw error

        return { success: true, data }
      } catch (err) {
        console.error('Get users error:', err)
        return { success: false, error: err.message }
      }
    },

    async updateUserRole(userId, role) {
      if (!this.isAdmin) {
        return { success: false, error: 'Unauthorized' }
      }

      try {
        const { data, error } = await supabase
          .from('users')
          .update({ role })
          .eq('id', userId)
          .select()

        if (error) throw error

        return { success: true, data: data[0] }
      } catch (err) {
        console.error('Update role error:', err)
        return { success: false, error: err.message }
      }
    },

    async toggleUserStatus(userId, isActive) {
      if (!this.isAdmin) {
        return { success: false, error: 'Unauthorized' }
      }

      try {
        const { data, error } = await supabase
          .from('users')
          .update({ is_active: isActive })
          .eq('id', userId)
          .select()

        if (error) throw error

        return { success: true, data: data[0] }
      } catch (err) {
        console.error('Toggle status error:', err)
        return { success: false, error: err.message }
      }
    }
  }
})


