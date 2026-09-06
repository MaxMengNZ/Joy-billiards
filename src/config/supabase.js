import { createClient } from '@supabase/supabase-js'

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY

if (!supabaseUrl || !supabaseAnonKey) {
  console.error('Missing Supabase environment variables. Please check your .env file.')
}

// Recovery credentials belong to the native App, not a website session.
const isRecoveryBridge = typeof window !== 'undefined' && ['/reset-password', '/app-reset'].includes(window.location.pathname)
export const supabase = createClient(supabaseUrl, supabaseAnonKey, {
  auth: { detectSessionInUrl: !isRecoveryBridge },
})

// Test connection
export const testConnection = async () => {
  try {
    // Simple count query to test connection
    const { count, error } = await supabase
      .from('users')
      .select('id', { count: 'exact', head: true })
    
    if (error) throw error
    
    console.log('✅ Supabase connection successful')
    return true
  } catch (error) {
    console.error('❌ Supabase connection failed:', error.message)
    return false
  }
}
