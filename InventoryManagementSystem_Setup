-- =================================================================
-- BAGIAN 1: PEMBUATAN TABEL
-- =================================================================

-- Tabel untuk data pemasok (suppliers)
CREATE TABLE public.suppliers (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    contact VARCHAR(100),
    address TEXT,
    email VARCHAR(255),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabel untuk data toko (stores)
CREATE TABLE public.stores (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    location VARCHAR(255),
    manager VARCHAR(255),
    phone VARCHAR(100),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabel untuk data barang (products)
CREATE TABLE public.products (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    price DECIMAL(15,2) NOT NULL,
    stock INTEGER NOT NULL,
    category VARCHAR(100),
    supplier_id UUID REFERENCES public.suppliers(id) ON DELETE SET NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabel untuk data penjualan (sales)
CREATE TABLE public.sales (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    month VARCHAR(20),
    sales_amount DECIMAL(15,2),
    profit_amount DECIMAL(15,2),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabel untuk profil pengguna (menyimpan role)
CREATE TABLE public.profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  name VARCHAR(255),
  role VARCHAR(50) DEFAULT 'pengguna' NOT NULL
);

-- =================================================================
-- BAGIAN 2: OTOMATISASI & DATA AWAL
-- =================================================================

-- Fungsi untuk membuat profil baru secara otomatis saat user mendaftar
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, name, role)
  VALUES (new.id, new.raw_user_meta_data->>'name', new.raw_user_meta_data->>'role');
  RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger yang menjalankan fungsi di atas
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();

-- Memasukkan data awal (sample data)
INSERT INTO public.suppliers (name, contact, address, email) VALUES
('Tech Corp', '081234567890', 'Jakarta Selatan', 'tech@corp.com'),
('Gadget Inc', '081234567891', 'Jakarta Utara', 'info@gadget.com'),
('Display Co', '081234567892', 'Jakarta Barat', 'sales@display.com');

INSERT INTO public.stores (name, location, manager, phone) VALUES
('Toko Pusat', 'Jakarta Pusat', 'John Doe', '021-1234567'),
('Toko Cabang Utara', 'Jakarta Utara', 'Jane Smith', '021-7654321');

INSERT INTO public.sales (month, sales_amount, profit_amount) VALUES
('Jan', 45000000, 12000000), ('Feb', 52000000, 15000000), ('Mar', 48000000, 13000000),
('Apr', 61000000, 18000000), ('May', 55000000, 16000000), ('Jun', 67000000, 20000000);

INSERT INTO public.products (name, price, stock, category, supplier_id) VALUES
('Laptop Gaming Pro', 15000000, 25, 'Elektronik', (SELECT id FROM suppliers WHERE name='Tech Corp')),
('Mouse Wireless Ergonomis', 350000, 100, 'Aksesoris', (SELECT id FROM suppliers WHERE name='Gadget Inc')),
('Keyboard Mechanical RGB', 750000, 50, 'Aksesoris', (SELECT id FROM suppliers WHERE name='Tech Corp')),
('Monitor 24 inch IPS', 2500000, 30, 'Elektronik', (SELECT id FROM suppliers WHERE name='Display Co'));


-- =================================================================
-- BAGIAN 3: KEAMANAN (ROW LEVEL SECURITY & POLICIES)
-- =================================================================

-- Fungsi helper untuk mendapatkan role pengguna yang sedang login
CREATE OR REPLACE FUNCTION get_user_role()
RETURNS TEXT AS $$
BEGIN
  RETURN (
    SELECT role FROM public.profiles WHERE id = auth.uid()
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Aktifkan Row Level Security (RLS) untuk semua tabel
ALTER TABLE public.suppliers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.stores ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.products ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.sales ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- Hapus policy lama jika ada (untuk memastikan setup bersih)
DROP POLICY IF EXISTS "Allow authenticated read access" ON public.suppliers;
DROP POLICY IF EXISTS "Allow admin full access" ON public.suppliers;
-- (Ulangi untuk tabel lain jika perlu)

-- ATURAN 1: SEMUA PENGGUNA (ADMIN & USER BIASA) BISA MELIHAT DATA
CREATE POLICY "Allow authenticated read access" ON public.suppliers FOR SELECT TO authenticated USING (true);
CREATE POLICY "Allow authenticated read access" ON public.stores FOR SELECT TO authenticated USING (true);
CREATE POLICY "Allow authenticated read access" ON public.products FOR SELECT TO authenticated USING (true);
CREATE POLICY "Allow authenticated read access" ON public.sales FOR SELECT TO authenticated USING (true);
CREATE POLICY "Users can view their own profile" ON public.profiles FOR SELECT TO authenticated USING (auth.uid() = id);

-- ATURAN 2: HANYA ADMIN YANG BISA MEMBUAT, MENGUBAH, DAN MENGHAPUS DATA
CREATE POLICY "Allow admin full access" ON public.suppliers FOR ALL USING (get_user_role() = 'admin') WITH CHECK (get_user_role() = 'admin');
CREATE POLICY "Allow admin full access" ON public.stores FOR ALL USING (get_user_role() = 'admin') WITH CHECK (get_user_role() = 'admin');
CREATE POLICY "Allow admin full access" ON public.products FOR ALL USING (get_user_role() = 'admin') WITH CHECK (get_user_role() = 'admin');
CREATE POLICY "Allow admin full access" ON public.sales FOR ALL USING (get_user_role() = 'admin') WITH CHECK (get_user_role() = 'admin');
CREATE POLICY "Allow admin full access on profiles" ON public.profiles FOR ALL USING (get_user_role() = 'admin') WITH CHECK (get_user_role() = 'admin');
