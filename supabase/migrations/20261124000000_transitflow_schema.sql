-- ============================================================================
-- TRANSITFLOW SL: Commercial Motorcycle Union Management & Financial Compliance System
-- Target: Urban Centres across Sierra Leone (Freetown, Lumley, Kissy, Wellington, etc.)
-- Alignment: UN SDG 11 (Target 11.2 - Sustainable Transport) & UN SDG 8 (Decent Work)
-- Stage 3 Supabase PostgreSQL Schema with 14 Interconnected Tables, RLS & RPC
-- ============================================================================

-- 1. Enable required extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ============================================================================
-- TABLE 1: profiles
-- User profiles linked to auth.users (Riders, Administrators, Safety Inspectors, Union Executives)
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    username TEXT UNIQUE NOT NULL,
    full_name TEXT NOT NULL,
    phone_number TEXT,
    role TEXT NOT NULL CHECK (role IN ('rider', 'admin', 'inspector', 'executive')),
    avatar_url TEXT,
    auth_provider TEXT NOT NULL DEFAULT 'email',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_profiles_role ON public.profiles(role);
CREATE INDEX IF NOT EXISTS idx_profiles_username ON public.profiles(username);

-- ============================================================================
-- TABLE 2: station_zones
-- Freetown Okada Union Station Zones & Operating Terminals
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.station_zones (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    zone_code TEXT UNIQUE NOT NULL,
    name TEXT UNIQUE NOT NULL,
    district TEXT NOT NULL DEFAULT 'Western Area Urban',
    city TEXT NOT NULL DEFAULT 'Freetown',
    coordinator_name TEXT NOT NULL,
    phone_contact TEXT,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_station_zones_code ON public.station_zones(zone_code);

-- ============================================================================
-- TABLE 3: riders
-- Registered Okada Commercial Motorcycle Riders
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.riders (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    rider_code TEXT UNIQUE NOT NULL, -- e.g. R001, R002, R003
    profile_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    full_name TEXT NOT NULL,
    phone_number TEXT NOT NULL,
    license_number TEXT UNIQUE NOT NULL,
    zone_id UUID NOT NULL REFERENCES public.station_zones(id) ON DELETE RESTRICT,
    emergency_contact_name TEXT,
    emergency_contact_phone TEXT,
    status TEXT NOT NULL DEFAULT 'ACTIVE' CHECK (status IN ('ACTIVE', 'SUSPENDED', 'INACTIVE')),
    registered_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_riders_rider_code ON public.riders(rider_code);
CREATE INDEX IF NOT EXISTS idx_riders_license ON public.riders(license_number);
CREATE INDEX IF NOT EXISTS idx_riders_zone_id ON public.riders(zone_id);

-- ============================================================================
-- TABLE 4: bikes
-- Commercial Motorcycles (Okadas) linked to Riders
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.bikes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    plate_number TEXT UNIQUE NOT NULL, -- e.g. BKE-101, BKE-202
    rider_id UUID NOT NULL REFERENCES public.riders(id) ON DELETE CASCADE,
    zone_id UUID REFERENCES public.station_zones(id) ON DELETE SET NULL,
    make TEXT NOT NULL DEFAULT 'Bajaj',
    model TEXT NOT NULL, -- e.g. 'Bajaj Boxer 150', 'TVS Star HLX'
    color TEXT NOT NULL DEFAULT 'Red',
    manufacture_year INT NOT NULL DEFAULT 2023,
    chassis_number TEXT,
    inspection_status TEXT NOT NULL DEFAULT 'PENDING' CHECK (inspection_status IN ('PENDING', 'PASSED', 'FLAGGED')),
    is_inspected BOOLEAN NOT NULL DEFAULT FALSE,
    total_dues_paid NUMERIC(14,2) NOT NULL DEFAULT 0.00 CHECK (total_dues_paid >= 0),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_bikes_plate ON public.bikes(plate_number);
CREATE INDEX IF NOT EXISTS idx_bikes_rider_id ON public.bikes(rider_id);
CREATE INDEX IF NOT EXISTS idx_bikes_inspection ON public.bikes(inspection_status);

-- ============================================================================
-- TABLE 5: fee_types
-- Official Union Fee Schedule & Tariff Rates
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.fee_types (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code TEXT UNIQUE NOT NULL, -- e.g. DAILY_LEVY, SAFETY_FINE, ANNUAL_PERMIT, CUSTOM
    name TEXT UNIQUE NOT NULL,
    description TEXT,
    default_amount NUMERIC(14,2) NOT NULL DEFAULT 0.00 CHECK (default_amount >= 0),
    billing_cycle TEXT NOT NULL CHECK (billing_cycle IN ('DAILY', 'PER_INCIDENT', 'ANNUAL', 'CUSTOM')),
    is_custom_allowed BOOLEAN NOT NULL DEFAULT FALSE,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_fee_types_code ON public.fee_types(code);

-- ============================================================================
-- TABLE 6: daily_logs
-- Immutable Financial Payment Ledger (Append-Only)
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.daily_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    log_code TEXT UNIQUE NOT NULL, -- e.g. LOG-20261124-001
    bike_id UUID NOT NULL REFERENCES public.bikes(id) ON DELETE RESTRICT,
    rider_id UUID NOT NULL REFERENCES public.riders(id) ON DELETE RESTRICT,
    zone_id UUID REFERENCES public.station_zones(id) ON DELETE SET NULL,
    fee_type_id UUID NOT NULL REFERENCES public.fee_types(id) ON DELETE RESTRICT,
    amount NUMERIC(14,2) NOT NULL CHECK (amount > 0),
    payment_method TEXT NOT NULL DEFAULT 'CASH_OFFICIAL' CHECK (payment_method IN ('CASH_OFFICIAL', 'ORANGE_MONEY', 'AFRICEL_MONEY', 'CARD', 'ONLINE')),
    recorded_by_profile_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    notes TEXT,
    paid_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_daily_logs_bike_id ON public.daily_logs(bike_id);
CREATE INDEX IF NOT EXISTS idx_daily_logs_rider_id ON public.daily_logs(rider_id);
CREATE INDEX IF NOT EXISTS idx_daily_logs_paid_at ON public.daily_logs(paid_at);
CREATE INDEX IF NOT EXISTS idx_daily_logs_code ON public.daily_logs(log_code);

-- TRIGGER TO ENFORCE IMMUTABILITY ON daily_logs (No UPDATE or DELETE allowed)
CREATE OR REPLACE FUNCTION public.prevent_daily_logs_modification()
RETURNS TRIGGER AS $$
BEGIN
    RAISE EXCEPTION 'Audit Violation: public.daily_logs is strictly append-only and immutable. UPDATE or DELETE operations are prohibited.';
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_immutable_daily_logs ON public.daily_logs;
CREATE TRIGGER trg_immutable_daily_logs
BEFORE UPDATE OR DELETE ON public.daily_logs
FOR EACH ROW EXECUTE FUNCTION public.prevent_daily_logs_modification();

-- ============================================================================
-- TABLE 7: payment_receipts
-- Verifiable Digital Payment Receipts
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.payment_receipts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    receipt_number TEXT UNIQUE NOT NULL, -- e.g. RCP-20261124-001
    daily_log_id UUID UNIQUE NOT NULL REFERENCES public.daily_logs(id) ON DELETE RESTRICT,
    rider_id UUID NOT NULL REFERENCES public.riders(id) ON DELETE RESTRICT,
    bike_id UUID NOT NULL REFERENCES public.bikes(id) ON DELETE RESTRICT,
    amount NUMERIC(14,2) NOT NULL CHECK (amount > 0),
    currency TEXT NOT NULL DEFAULT 'SLE', -- Sierra Leonean Leone
    issued_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_payment_receipts_number ON public.payment_receipts(receipt_number);
CREATE INDEX IF NOT EXISTS idx_payment_receipts_rider_id ON public.payment_receipts(rider_id);

-- ============================================================================
-- TABLE 8: safety_inspections
-- Regular Roadworthiness & Rider Safety Compliance Inspections
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.safety_inspections (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    inspection_code TEXT UNIQUE NOT NULL,
    bike_id UUID NOT NULL REFERENCES public.bikes(id) ON DELETE CASCADE,
    rider_id UUID NOT NULL REFERENCES public.riders(id) ON DELETE CASCADE,
    inspector_profile_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    brakes_ok BOOLEAN NOT NULL DEFAULT TRUE,
    lights_ok BOOLEAN NOT NULL DEFAULT TRUE,
    tires_ok BOOLEAN NOT NULL DEFAULT TRUE,
    helmet_gear_ok BOOLEAN NOT NULL DEFAULT TRUE,
    status TEXT NOT NULL DEFAULT 'PENDING' CHECK (status IN ('PASSED', 'PENDING', 'FLAGGED')),
    remarks TEXT,
    inspected_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    expires_at TIMESTAMPTZ NOT NULL DEFAULT (NOW() + INTERVAL '90 days')
);

CREATE INDEX IF NOT EXISTS idx_inspections_bike_id ON public.safety_inspections(bike_id);
CREATE INDEX IF NOT EXISTS idx_inspections_status ON public.safety_inspections(status);

-- ============================================================================
-- TABLE 9: station_permits
-- Periodic Station Operating Permits & Zone Clearances
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.station_permits (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    permit_code TEXT UNIQUE NOT NULL,
    bike_id UUID NOT NULL REFERENCES public.bikes(id) ON DELETE CASCADE,
    rider_id UUID NOT NULL REFERENCES public.riders(id) ON DELETE CASCADE,
    zone_id UUID NOT NULL REFERENCES public.station_zones(id) ON DELETE RESTRICT,
    permit_type TEXT NOT NULL DEFAULT 'ANNUAL_OPERATIONAL',
    issued_date DATE NOT NULL DEFAULT CURRENT_DATE,
    expiry_date DATE NOT NULL DEFAULT (CURRENT_DATE + INTERVAL '1 year'),
    fee_amount NUMERIC(14,2) NOT NULL DEFAULT 100000.00 CHECK (fee_amount >= 0),
    status TEXT NOT NULL DEFAULT 'ACTIVE' CHECK (status IN ('ACTIVE', 'EXPIRED', 'REVOKED')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_permits_bike ON public.station_permits(bike_id);
CREATE INDEX IF NOT EXISTS idx_permits_code ON public.station_permits(permit_code);

-- ============================================================================
-- TABLE 10: levy_schedules
-- Daily Levy Schedules & Collection Tracking
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.levy_schedules (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    bike_id UUID NOT NULL REFERENCES public.bikes(id) ON DELETE CASCADE,
    rider_id UUID NOT NULL REFERENCES public.riders(id) ON DELETE CASCADE,
    schedule_date DATE NOT NULL DEFAULT CURRENT_DATE,
    expected_amount NUMERIC(14,2) NOT NULL DEFAULT 25000.00,
    paid_amount NUMERIC(14,2) NOT NULL DEFAULT 0.00,
    status TEXT NOT NULL DEFAULT 'PENDING' CHECK (status IN ('PAID', 'PENDING', 'PARTIAL', 'OVERDUE')),
    daily_log_id UUID REFERENCES public.daily_logs(id) ON DELETE SET NULL
);

CREATE INDEX IF NOT EXISTS idx_levy_schedules_date ON public.levy_schedules(schedule_date);
CREATE INDEX IF NOT EXISTS idx_levy_schedules_bike ON public.levy_schedules(bike_id);

-- ============================================================================
-- TABLE 11: compliance_disputes
-- Rider Payment & Safety Fine Disputes / Appeals
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.compliance_disputes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    ticket_code TEXT UNIQUE NOT NULL,
    rider_id UUID NOT NULL REFERENCES public.riders(id) ON DELETE CASCADE,
    bike_id UUID NOT NULL REFERENCES public.bikes(id) ON DELETE CASCADE,
    daily_log_id UUID REFERENCES public.daily_logs(id) ON DELETE SET NULL,
    subject TEXT NOT NULL,
    description TEXT NOT NULL,
    status TEXT NOT NULL DEFAULT 'OPEN' CHECK (status IN ('OPEN', 'IN_REVIEW', 'RESOLVED', 'REJECTED')),
    resolution_notes TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    resolved_at TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_disputes_ticket ON public.compliance_disputes(ticket_code);
CREATE INDEX IF NOT EXISTS idx_disputes_rider ON public.compliance_disputes(rider_id);

-- ============================================================================
-- TABLE 12: union_announcements
-- Broadcast Announcements for Okada Union Members and Stations
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.union_announcements (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title TEXT NOT NULL,
    message TEXT NOT NULL,
    zone_id UUID REFERENCES public.station_zones(id) ON DELETE SET NULL,
    priority TEXT NOT NULL DEFAULT 'NORMAL' CHECK (priority IN ('LOW', 'NORMAL', 'HIGH', 'URGENT')),
    published_by_profile_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    published_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================================================
-- TABLE 13: notifications
-- User-Targeted Alerts (Levy dues, Inspection reminders, Dispute resolutions)
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    recipient_profile_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    body TEXT NOT NULL,
    category TEXT NOT NULL DEFAULT 'PAYMENT' CHECK (category IN ('PAYMENT', 'INSPECTION', 'PERMIT', 'SAFETY', 'GENERAL')),
    is_read BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_notifications_recipient ON public.notifications(recipient_profile_id);

-- ============================================================================
-- TABLE 14: audit_trail_logs
-- Immutable Security & Governance Audit Log
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.audit_trail_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    actor_profile_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    action TEXT NOT NULL,
    table_name TEXT NOT NULL,
    record_id TEXT NOT NULL,
    details JSONB NOT NULL DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_audit_created ON public.audit_trail_logs(created_at);

-- ============================================================================
-- TRANSACTIONAL RPC FUNCTION: process_union_payment
-- Performs atomic validation, ledger append, bike dues increment, receipt generation,
-- and audit trail entry inside a single database transaction.
-- ============================================================================
CREATE OR REPLACE FUNCTION public.process_union_payment(
    p_bike_id UUID,
    p_rider_id UUID,
    p_fee_type_id UUID,
    p_amount NUMERIC,
    p_payment_method TEXT DEFAULT 'CASH_OFFICIAL',
    p_notes TEXT DEFAULT NULL,
    p_recorder_id UUID DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_log_id UUID;
    v_receipt_id UUID;
    v_zone_id UUID;
    v_log_code TEXT;
    v_receipt_number TEXT;
    v_now TIMESTAMPTZ := NOW();
    v_total_dues NUMERIC(14,2);
    v_random_suffix TEXT;
    v_rider_profile_id UUID;
BEGIN
    -- 1. Validation
    IF p_amount IS NULL OR p_amount <= 0 THEN
        RAISE EXCEPTION 'Invalid payment amount. Amount must be strictly greater than zero.';
    END IF;

    -- 2. Verify Bike and obtain zone
    SELECT zone_id, total_dues_paid INTO v_zone_id, v_total_dues
    FROM public.bikes
    WHERE id = p_bike_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Motorcycle with ID % not found.', p_bike_id;
    END IF;

    -- 3. Verify Rider
    SELECT profile_id INTO v_rider_profile_id
    FROM public.riders
    WHERE id = p_rider_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Rider with ID % not found.', p_rider_id;
    END IF;

    -- 4. Generate unique business codes
    v_random_suffix := LPAD(FLOOR(RANDOM() * 10000)::TEXT, 4, '0');
    v_log_code := 'LOG-' || TO_CHAR(v_now, 'YYYYMMDD') || '-' || v_random_suffix;
    v_receipt_number := 'RCP-' || TO_CHAR(v_now, 'YYYYMMDD') || '-' || v_random_suffix;

    -- 5. Insert Immutable Daily Log
    INSERT INTO public.daily_logs (
        log_code,
        bike_id,
        rider_id,
        zone_id,
        fee_type_id,
        amount,
        payment_method,
        recorded_by_profile_id,
        notes,
        paid_at
    ) VALUES (
        v_log_code,
        p_bike_id,
        p_rider_id,
        v_zone_id,
        p_fee_type_id,
        p_amount,
        p_payment_method,
        p_recorder_id,
        p_notes,
        v_now
    ) RETURNING id INTO v_log_id;

    -- 6. Insert Official Payment Receipt
    INSERT INTO public.payment_receipts (
        receipt_number,
        daily_log_id,
        rider_id,
        bike_id,
        amount,
        currency,
        issued_at
    ) VALUES (
        v_receipt_number,
        v_log_id,
        p_rider_id,
        p_bike_id,
        p_amount,
        'SLE',
        v_now
    ) RETURNING id INTO v_receipt_id;

    -- 7. Atomically increment bike cumulative total dues paid
    UPDATE public.bikes
    SET total_dues_paid = total_dues_paid + p_amount,
        updated_at = v_now
    WHERE id = p_bike_id
    RETURNING total_dues_paid INTO v_total_dues;

    -- 8. Record in audit trail
    INSERT INTO public.audit_trail_logs (
        actor_profile_id,
        action,
        table_name,
        record_id,
        details
    ) VALUES (
        p_recorder_id,
        'PROCESS_PAYMENT',
        'daily_logs',
        v_log_id::TEXT,
        jsonb_build_object(
            'amount', p_amount,
            'log_code', v_log_code,
            'receipt_number', v_receipt_number,
            'payment_method', p_payment_method,
            'bike_id', p_bike_id,
            'rider_id', p_rider_id
        )
    );

    -- 9. Create notification for rider if linked to a profile
    IF v_rider_profile_id IS NOT NULL THEN
        INSERT INTO public.notifications (
            recipient_profile_id,
            title,
            body,
            category,
            created_at
        ) VALUES (
            v_rider_profile_id,
            'Payment Confirmed',
            'Your payment of Le ' || TO_CHAR(p_amount, 'FM999,999,990.00') || ' has been recorded under receipt ' || v_receipt_number || '.',
            'PAYMENT',
            v_now
        );
    END IF;

    -- 10. Return structured result
    RETURN jsonb_build_object(
        'success', true,
        'log_id', v_log_id,
        'log_code', v_log_code,
        'receipt_id', v_receipt_id,
        'receipt_number', v_receipt_number,
        'amount', p_amount,
        'total_dues_paid', v_total_dues,
        'paid_at', v_now
    );
END;
$$;

-- ============================================================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- ============================================================================
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.station_zones ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.riders ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.bikes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.fee_types ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.daily_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.payment_receipts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.safety_inspections ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.station_permits ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.levy_schedules ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.compliance_disputes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.union_announcements ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.audit_trail_logs ENABLE ROW LEVEL SECURITY;

-- Read policies (Allow public read for active union operations, lookup, and transparency)
CREATE POLICY "Public read station zones" ON public.station_zones FOR SELECT USING (true);
CREATE POLICY "Public read fee types" ON public.fee_types FOR SELECT USING (true);
CREATE POLICY "Public read announcements" ON public.union_announcements FOR SELECT USING (true);
CREATE POLICY "Read profiles" ON public.profiles FOR SELECT USING (true);
CREATE POLICY "Read riders" ON public.riders FOR SELECT USING (true);
CREATE POLICY "Read bikes" ON public.bikes FOR SELECT USING (true);
CREATE POLICY "Read daily logs" ON public.daily_logs FOR SELECT USING (true);
CREATE POLICY "Read receipts" ON public.payment_receipts FOR SELECT USING (true);
CREATE POLICY "Read inspections" ON public.safety_inspections FOR SELECT USING (true);
CREATE POLICY "Read permits" ON public.station_permits FOR SELECT USING (true);
CREATE POLICY "Read levy schedules" ON public.levy_schedules FOR SELECT USING (true);
CREATE POLICY "Read disputes" ON public.compliance_disputes FOR SELECT USING (true);
CREATE POLICY "Read notifications" ON public.notifications FOR SELECT USING (true);
CREATE POLICY "Read audit logs" ON public.audit_trail_logs FOR SELECT USING (true);

-- Write policies (Authenticated users, admins, inspectors, and RPC operations)
CREATE POLICY "Insert daily logs" ON public.daily_logs FOR INSERT WITH CHECK (true);
CREATE POLICY "Insert payment receipts" ON public.payment_receipts FOR INSERT WITH CHECK (true);
CREATE POLICY "Update bikes" ON public.bikes FOR UPDATE USING (true);
CREATE POLICY "Insert riders" ON public.riders FOR INSERT WITH CHECK (true);
CREATE POLICY "Update riders" ON public.riders FOR UPDATE USING (true);
CREATE POLICY "Insert bikes" ON public.bikes FOR INSERT WITH CHECK (true);
CREATE POLICY "Insert inspections" ON public.safety_inspections FOR INSERT WITH CHECK (true);
CREATE POLICY "Update inspections" ON public.safety_inspections FOR UPDATE USING (true);
CREATE POLICY "Insert disputes" ON public.compliance_disputes FOR INSERT WITH CHECK (true);
CREATE POLICY "Update disputes" ON public.compliance_disputes FOR UPDATE USING (true);
CREATE POLICY "Insert notifications" ON public.notifications FOR INSERT WITH CHECK (true);
CREATE POLICY "Update notifications" ON public.notifications FOR UPDATE USING (true);
CREATE POLICY "Insert audit logs" ON public.audit_trail_logs FOR INSERT WITH CHECK (true);
