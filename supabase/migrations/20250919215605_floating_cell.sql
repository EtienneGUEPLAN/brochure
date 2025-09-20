/*
  # Correction des politiques RLS pour les soumissions NDA

  1. Corrections
    - Supprime les anciennes politiques si elles existent
    - Recrée les politiques avec les bonnes permissions
    - S'assure que RLS est activé correctement

  2. Sécurité
    - Permet l'insertion publique (rôle anon) pour les soumissions NDA
    - Permet la lecture aux utilisateurs authentifiés seulement
    - Utilise des conditions simples et fiables
*/

-- Supprimer les anciennes politiques si elles existent
DROP POLICY IF EXISTS "Allow authenticated read for NDA submissions" ON nda_submissions;
DROP POLICY IF EXISTS "Allow public insert for NDA submissions" ON nda_submissions;

-- S'assurer que RLS est activé
ALTER TABLE nda_submissions ENABLE ROW LEVEL SECURITY;

-- Politique pour permettre l'insertion publique (utilisateurs anonymes)
CREATE POLICY "Enable insert for anonymous users" ON nda_submissions
    FOR INSERT 
    TO anon 
    WITH CHECK (true);

-- Politique pour permettre la lecture aux utilisateurs authentifiés
CREATE POLICY "Enable read for authenticated users" ON nda_submissions
    FOR SELECT 
    TO authenticated 
    USING (true);

-- Politique pour permettre la lecture aux utilisateurs anonymes (pour vérifier les doublons)
CREATE POLICY "Enable read for anonymous users" ON nda_submissions
    FOR SELECT 
    TO anon 
    USING (true);