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
      }

      // Listen for auth changes
      supabase.auth.onAuthStateChange(async (event, session) => {
        this.session = session
        this.user = session?.user || null
        
        if (session?.user) {
          await this.fetchProfile()
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

        if (error) throw error

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
        const { data, error } = await supabase.auth.signInWithPassword({
          email,
          password
        })

        if (error) throw error

        this.session = data.session
        this.user = data.user
        await this.fetchProfile()

        return { success: true, data }
      } catch (err) {
        this.error = err.message
        console.error('Sign in error:', err)
        return { success: false, error: err.message }
      } finally {
        this.loading = false
      }
    },

    async signOut() {
      this.loading = true
      this.error = null

      try {
        const { error } = await supabase.auth.signOut()
        if (error) throw error

        this.user = null
        this.profile = null
        this.session = null

        return { success: true }
      } catch (err) {
        this.error = err.message
        console.error('Sign out error:', err)
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
        const { error } = await supabase.auth.updateUser({
          password: newPassword
        })

        if (error) throw error

        return { success: true }
      } catch (err) {
        this.error = err.message
        console.error('Update password error:', err)
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


