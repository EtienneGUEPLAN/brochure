/*
  # Création de la table pour les soumissions NDA

  1. Nouvelles Tables
    - `nda_submissions`
      - `id` (uuid, clé primaire)
      - `company_name` (text, nom de la société)
      - `representative_name` (text, nom du représentant)
      - `email` (text, email professionnel)
      - `project_name` (text, nom du projet)
      - `ip_address` (text, adresse IP pour traçabilité)
      - `user_agent` (text, navigateur utilisé)
      - `created_at` (timestamp, date de soumission)
      - `updated_at` (timestamp, dernière modification)

  2. Sécurité
    - Activation du RLS sur la table `nda_submissions`
    - Politique pour permettre l'insertion publique (formulaire accessible sans authentification)
    - Politique pour la lecture restreinte aux utilisateurs authentifiés
*/

CREATE TABLE IF NOT EXISTS nda_submissions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  company_name text NOT NULL,
  representative_name text NOT NULL,
  email text NOT NULL,
  project_name text NOT NULL,
  ip_address text,
  user_agent text,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Activation du RLS
ALTER TABLE nda_submissions ENABLE ROW LEVEL SECURITY;

-- Politique pour permettre l'insertion publique (formulaire NDA)
CREATE POLICY "Allow public insert for NDA submissions"
  ON nda_submissions
  FOR INSERT
  TO anon
  WITH CHECK (true);

-- Politique pour la lecture (uniquement pour les utilisateurs authentifiés)
CREATE POLICY "Allow authenticated read for NDA submissions"
  ON nda_submissions
  FOR SELECT
  TO authenticated
  USING (true);

-- Index pour améliorer les performances de recherche
CREATE INDEX IF NOT EXISTS idx_nda_submissions_email ON nda_submissions(email);
CREATE INDEX IF NOT EXISTS idx_nda_submissions_created_at ON nda_submissions(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_nda_submissions_company ON nda_submissions(company_name);

-- Fonction pour mettre à jour automatiquement updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ language 'plpgsql';

-- Trigger pour mettre à jour updated_at automatiquement
CREATE TRIGGER update_nda_submissions_updated_at
  BEFORE UPDATE ON nda_submissions
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();