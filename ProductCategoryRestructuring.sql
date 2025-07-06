-- 1. BUAT TABEL BARU UNTUK KATEGORI
CREATE TABLE public.categories (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    name VARCHAR(255) NOT NULL UNIQUE, -- Nama kategori harus unik
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. UBAH TABEL 'products'
-- Hapus kolom 'category' yang lama (bertipe teks)
ALTER TABLE public.products DROP COLUMN category;

-- Tambahkan kolom 'category_id' yang baru sebagai penghubung (foreign key) ke tabel 'categories'
ALTER TABLE public.products
ADD COLUMN category_id UUID REFERENCES public.categories(id) ON DELETE SET NULL;


-- 3. MASUKKAN DATA AWAL UNTUK KATEGORI
INSERT INTO public.categories (name, description) VALUES
('Elektronik', 'Barang-barang elektronik seperti laptop, HP, dan aksesorisnya.'),
('Aksesoris', 'Aksesoris pelengkap untuk perangkat elektronik.'),
('Perabotan', 'Perabotan rumah tangga dan kantor.');

-- 4. PERBARUI DATA PRODUK YANG SUDAH ADA (AGAR TERHUBUNG KE KATEGORI BARU)
-- Sesuaikan ini jika Anda punya data produk yang berbeda
UPDATE public.products SET category_id = (SELECT id FROM categories WHERE name = 'Elektronik') WHERE name LIKE '%Laptop%' OR name LIKE '%Monitor%';
UPDATE public.products SET category_id = (SELECT id FROM categories WHERE name = 'Aksesoris') WHERE name LIKE '%Mouse%' OR name LIKE '%Keyboard%';


-- 5. TAMBAHKAN KEAMANAN (RLS) UNTUK TABEL KATEGORI
ALTER TABLE public.categories ENABLE ROW LEVEL SECURITY;

-- Aturan: Semua pengguna bisa melihat kategori
CREATE POLICY "Allow authenticated read access on categories" ON public.categories FOR SELECT TO authenticated USING (true);

-- Aturan: Hanya admin yang bisa mengelola kategori
CREATE POLICY "Allow admin full access on categories" ON public.categories FOR ALL USING (get_user_role() = 'admin') WITH CHECK (get_user_role() = 'admin');
