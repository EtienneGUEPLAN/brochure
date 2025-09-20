import { createClient } from '@supabase/supabase-js';

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL;
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY;

if (!supabaseUrl || !supabaseAnonKey) {
  throw new Error('Variables d\'environnement Supabase manquantes');
}

export const supabase = createClient(supabaseUrl, supabaseAnonKey);

// Types pour TypeScript
export interface NDASubmission {
  id?: string;
  company_name: string;
  representative_name: string;
  email: string;
  project_name: string;
  ip_address?: string;
  user_agent?: string;
  created_at?: string;
  updated_at?: string;
}

// Fonction pour soumettre un NDA
export async function submitNDA(data: Omit<NDASubmission, 'id' | 'created_at' | 'updated_at'>) {
  try {
    const { data: result, error } = await supabase
      .from('nda_submissions')
      .insert([data])
      .select()
      .single();

    if (error) {
      console.error('Erreur lors de la soumission NDA:', error);
      throw error;
    }

    return result;
  } catch (error) {
    console.error('Erreur lors de la soumission NDA:', error);
    throw error;
  }
}

// Fonction pour récupérer toutes les soumissions NDA (pour les admins)
export async function getNDASubmissions() {
  try {
    const { data, error } = await supabase
      .from('nda_submissions')
      .select('*')
      .order('created_at', { ascending: false });

    if (error) {
      console.error('Erreur lors de la récupération des soumissions:', error);
      throw error;
    }

    return data;
  } catch (error) {
    console.error('Erreur lors de la récupération des soumissions:', error);
    throw error;
  }
}

// Fonction pour vérifier si un email a déjà soumis un NDA
export async function checkExistingNDA(email: string) {
  try {
    const { data, error } = await supabase
      .from('nda_submissions')
      .select('id, created_at, company_name')
      .eq('email', email)
      .order('created_at', { ascending: false })
      .limit(1);

    if (error) {
      console.error('Erreur lors de la vérification:', error);
      throw error;
    }

    return data && data.length > 0 ? data[0] : null;
  } catch (error) {
    console.error('Erreur lors de la vérification:', error);
    throw error;
  }
}