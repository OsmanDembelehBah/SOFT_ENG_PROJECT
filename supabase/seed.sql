-- ============================================================================
-- TRANSITFLOW SL: Seed Data for Supabase PostgreSQL
-- Realistic Freetown Okada Union Initial State aligned with Stage 1 Report
-- ============================================================================

-- 1. SEED STATION ZONES
INSERT INTO public.station_zones (id, zone_code, name, district, city, coordinator_name, phone_contact, is_active)
VALUES
    ('11111111-1111-1111-1111-111111111001', 'LMJ-01', 'Lumley Junction', 'Western Area Urban', 'Freetown', 'Pa Sahr Fofanah', '+232 76 112233', true),
    ('11111111-1111-1111-1111-111111111002', 'WEL-02', 'Wellington Station', 'Western Area Urban', 'Freetown', 'Chief Abu Kargbo', '+232 77 223344', true),
    ('11111111-1111-1111-1111-111111111003', 'KSY-03', 'Kissy Road Station', 'Western Area Urban', 'Freetown', 'Amadu Bundu', '+232 78 334455', true),
    ('11111111-1111-1111-1111-111111111004', 'ABD-04', 'Aberdeen Station', 'Western Area Urban', 'Freetown', 'Momoh Tarawally', '+232 79 445566', true),
    ('11111111-1111-1111-1111-111111111005', 'CCX-05', 'Congo Cross', 'Western Area Urban', 'Freetown', 'Ibrahim Turay', '+232 88 556677', true),
    ('11111111-1111-1111-1111-111111111006', 'CTR-06', 'Central Station', 'Western Area Urban', 'Freetown', 'Morlai Koroma', '+232 30 667788', true)
ON CONFLICT (zone_code) DO NOTHING;

-- 2. SEED FEE TYPES (Tariff Rates in Sierra Leonean Leones)
INSERT INTO public.fee_types (id, code, name, description, default_amount, billing_cycle, is_custom_allowed, is_active)
VALUES
    ('22222222-2222-2222-2222-222222222001', 'DAILY_LEVY', 'Daily Levy', 'Standard daily operational union road dues', 25000.00, 'DAILY', false, true),
    ('22222222-2222-2222-2222-222222222002', 'SAFETY_FINE', 'Safety Fine', 'Fine for helmet, lighting, or traffic non-compliance', 15000.00, 'PER_INCIDENT', false, true),
    ('22222222-2222-2222-2222-222222222003', 'ANNUAL_PERMIT', 'Annual Permit', 'Yearly union terminal registration & operational badge', 100000.00, 'ANNUAL', false, true),
    ('22222222-2222-2222-2222-222222222004', 'CUSTOM_PAYMENT', 'Custom Payment', 'Special levies, welfare contributions, or penalty arrears', 0.00, 'CUSTOM', true, true)
ON CONFLICT (code) DO NOTHING;

-- 3. SEED PROFILES
-- Note: In production Supabase, profiles link to auth.users. Here we provide mock UUIDs for standalone SQL testing.
INSERT INTO public.profiles (id, username, full_name, phone_number, role, avatar_url, auth_provider)
VALUES
    ('33333333-3333-3333-3333-333333333001', 'admin_usman', 'Alhaji Osman Bah (Admin)', '+232 76 123456', 'admin', 'https://api.dicebear.com/7.x/bottts/svg?seed=admin', 'email'),
    ('33333333-3333-3333-3333-333333333002', 'inspector_alpha', 'Officer Alpha Sesay', '+232 77 998877', 'inspector', 'https://api.dicebear.com/7.x/bottts/svg?seed=alpha', 'email'),
    ('33333333-3333-3333-3333-333333333003', 'exec_mohamed', 'Chief Mohamed Mansaray', '+232 78 443322', 'executive', 'https://api.dicebear.com/7.x/bottts/svg?seed=exec', 'email'),
    ('33333333-3333-3333-3333-333333333004', 'R001', 'Alhaji Bah', '+232 76 123456', 'rider', 'https://api.dicebear.com/7.x/bottts/svg?seed=R001', 'email'),
    ('33333333-3333-3333-3333-333333333005', 'R002', 'Siddiq Kamara', '+232 88 987654', 'rider', 'https://api.dicebear.com/7.x/bottts/svg?seed=R002', 'email'),
    ('33333333-3333-3333-3333-333333333006', 'R003', 'Ibrahim Bah', '+232 88 057322', 'rider', 'https://api.dicebear.com/7.x/bottts/svg?seed=R003', 'email')
ON CONFLICT (id) DO NOTHING;

-- 4. SEED RIDERS
INSERT INTO public.riders (id, rider_code, profile_id, full_name, phone_number, license_number, zone_id, emergency_contact_name, emergency_contact_phone, status, registered_at)
VALUES
    ('44444444-4444-4444-4444-444444444001', 'R001', '33333333-3333-3333-3333-333333333004', 'Alhaji Bah', '076123456', 'SL-LIC-9981', '11111111-1111-1111-1111-111111111001', 'Fatmata Bah', '076998811', 'ACTIVE', NOW() - INTERVAL '60 days'),
    ('44444444-4444-4444-4444-444444444002', 'R002', '33333333-3333-3333-3333-333333333005', 'Siddiq Kamara', '088987654', 'SL-LIC-4432', '11111111-1111-1111-1111-111111111006', 'Kadiatu Kamara', '088223344', 'ACTIVE', NOW() - INTERVAL '45 days'),
    ('44444444-4444-4444-4444-444444444003', 'R003', '33333333-3333-3333-3333-333333333006', 'Ibrahim Bah', '088057322', 'SL-LIC-8812', '11111111-1111-1111-1111-111111111001', 'Mariama Bah', '077556677', 'ACTIVE', NOW() - INTERVAL '10 days'),
    ('44444444-4444-4444-4444-444444444004', 'R004', NULL, 'Santigie Koroma', '077334455', 'SL-LIC-7721', '11111111-1111-1111-1111-111111111003', 'Zainab Koroma', '077889900', 'ACTIVE', NOW() - INTERVAL '30 days'),
    ('44444444-4444-4444-4444-444444444005', 'R005', NULL, 'Brima Bangura', '078990011', 'SL-LIC-5510', '11111111-1111-1111-1111-111111111002', 'Hawa Bangura', '078112233', 'ACTIVE', NOW() - INTERVAL '20 days'),
    ('44444444-4444-4444-4444-444444444006', 'R006', NULL, 'Dauda Conteh', '076554433', 'SL-LIC-6623', '11111111-1111-1111-1111-111111111005', 'Aminata Conteh', '076223344', 'ACTIVE', NOW() - INTERVAL '50 days')
ON CONFLICT (rider_code) DO NOTHING;

-- 5. SEED MOTORCYCLES (BIKES)
INSERT INTO public.bikes (id, plate_number, rider_id, zone_id, make, model, color, manufacture_year, chassis_number, inspection_status, is_inspected, total_dues_paid)
VALUES
    ('55555555-5555-5555-5555-555555555001', 'BKE-101', '44444444-4444-4444-4444-444444444001', '11111111-1111-1111-1111-111111111001', 'Bajaj', 'Bajaj Boxer 150', 'Red', 2023, 'MD2A18AX8NC10101', 'PASSED', true, 75000.00),
    ('55555555-5555-5555-5555-555555555002', 'BKE-202', '44444444-4444-4444-4444-444444444002', '11111111-1111-1111-1111-111111111006', 'TVS', 'TVS Star HLX', 'Blue', 2022, 'MD6A22BY9MC20202', 'FLAGGED', false, 45000.00),
    ('55555555-5555-5555-5555-555555555003', 'BKE-103', '44444444-4444-4444-4444-444444444003', '11111111-1111-1111-1111-111111111001', 'TVS', 'TVS Star', 'Black', 2024, 'MD6A25CZ2PC30303', 'PASSED', true, 0.00),
    ('55555555-5555-5555-5555-555555555004', 'BKE-304', '44444444-4444-4444-4444-444444444004', '11111111-1111-1111-1111-111111111003', 'Haojue', 'Haojue 125', 'Silver', 2023, 'LC3A19DX4NC40404', 'PASSED', true, 50000.00),
    ('55555555-5555-5555-5555-555555555005', 'BKE-405', '44444444-4444-4444-4444-444444444005', '11111111-1111-1111-1111-111111111002', 'Bajaj', 'Bajaj Boxer 150', 'Yellow', 2021, 'MD2A15EX5MC50505', 'PENDING', false, 25000.00),
    ('55555555-5555-5555-5555-555555555006', 'BKE-506', '44444444-4444-4444-4444-444444444006', '11111111-1111-1111-1111-111111111005', 'TVS', 'TVS XL 100', 'White', 2023, 'MD6A18FZ7NC60606', 'PASSED', true, 100000.00)
ON CONFLICT (plate_number) DO NOTHING;

-- 6. SEED IMMUTABLE DAILY LOGS
INSERT INTO public.daily_logs (id, log_code, bike_id, rider_id, zone_id, fee_type_id, amount, payment_method, recorded_by_profile_id, notes, paid_at)
VALUES
    ('66666666-6666-6666-6666-666666666001', 'LOG-20261120-001', '55555555-5555-5555-5555-555555555001', '44444444-4444-4444-4444-444444444001', '11111111-1111-1111-1111-111111111001', '22222222-2222-2222-2222-222222222001', 25000.00, 'CASH_OFFICIAL', '33333333-3333-3333-3333-333333333001', 'Regular morning levy payment at Lumley Junction', NOW() - INTERVAL '4 days'),
    ('66666666-6666-6666-6666-666666666002', 'LOG-20261121-002', '55555555-5555-5555-5555-555555555001', '44444444-4444-4444-4444-444444444001', '11111111-1111-1111-1111-111111111001', '22222222-2222-2222-2222-222222222001', 25000.00, 'ORANGE_MONEY', '33333333-3333-3333-3333-333333333001', 'Mobile money levy transaction', NOW() - INTERVAL '3 days'),
    ('66666666-6666-6666-6666-666666666003', 'LOG-20261122-003', '55555555-5555-5555-5555-555555555001', '44444444-4444-4444-4444-444444444001', '11111111-1111-1111-1111-111111111001', '22222222-2222-2222-2222-222222222001', 25000.00, 'CASH_OFFICIAL', '33333333-3333-3333-3333-333333333001', 'Lumley Terminal gate clearance', NOW() - INTERVAL '2 days'),
    ('66666666-6666-6666-6666-666666666004', 'LOG-20261122-004', '55555555-5555-5555-5555-555555555002', '44444444-4444-4444-4444-444444444002', '11111111-1111-1111-1111-111111111006', '22222222-2222-2222-2222-222222222002', 15000.00, 'CASH_OFFICIAL', '33333333-3333-3333-3333-333333333002', 'Safety fine: Missing side mirror at Central Station', NOW() - INTERVAL '2 days'),
    ('66666666-6666-6666-6666-666666666005', 'LOG-20261123-005', '55555555-5555-5555-5555-555555555002', '44444444-4444-4444-4444-444444444002', '11111111-1111-1111-1111-111111111006', '22222222-2222-2222-2222-222222222002', 15000.00, 'CASH_OFFICIAL', '33333333-3333-3333-3333-333333333002', 'Safety fine: Passenger unfastened helmet', NOW() - INTERVAL '1 day'),
    ('66666666-6666-6666-6666-666666666006', 'LOG-20261123-006', '55555555-5555-5555-5555-555555555002', '44444444-4444-4444-4444-444444444002', '11111111-1111-1111-1111-111111111006', '22222222-2222-2222-2222-222222222002', 15000.00, 'CASH_OFFICIAL', '33333333-3333-3333-3333-333333333002', 'Safety fine: Tail light failure', NOW() - INTERVAL '18 hours'),
    ('66666666-6666-6666-6666-666666666007', 'LOG-20261123-007', '55555555-5555-5555-5555-555555555004', '44444444-4444-4444-4444-444444444004', '11111111-1111-1111-1111-111111111003', '22222222-2222-2222-2222-222222222001', 25000.00, 'AFRICEL_MONEY', '33333333-3333-3333-3333-333333333001', 'Kissy Road Station terminal dues', NOW() - INTERVAL '12 hours'),
    ('66666666-6666-6666-6666-666666666008', 'LOG-20261124-008', '55555555-5555-5555-5555-555555555004', '44444444-4444-4444-4444-444444444004', '11111111-1111-1111-1111-111111111003', '22222222-2222-2222-2222-222222222001', 25000.00, 'CASH_OFFICIAL', '33333333-3333-3333-3333-333333333001', 'Daily levy collection Kissy', NOW() - INTERVAL '2 hours'),
    ('66666666-6666-6666-6666-666666666009', 'LOG-20261123-009', '55555555-5555-5555-5555-555555555005', '44444444-4444-4444-4444-444444444005', '11111111-1111-1111-1111-111111111002', '22222222-2222-2222-2222-222222222001', 25000.00, 'CASH_OFFICIAL', '33333333-3333-3333-3333-333333333001', 'Wellington Station regular dues', NOW() - INTERVAL '15 hours'),
    ('66666666-6666-6666-6666-666666666010', 'LOG-20261120-010', '55555555-5555-5555-5555-555555555006', '44444444-4444-4444-4444-444444444006', '11111111-1111-1111-1111-111111111005', '22222222-2222-2222-2222-222222222003', 100000.00, 'ONLINE', '33333333-3333-3333-3333-333333333001', 'Annual Station Operating Permit 2026-2027', NOW() - INTERVAL '5 days')
ON CONFLICT (log_code) DO NOTHING;

-- 7. SEED OFFICIAL PAYMENT RECEIPTS
INSERT INTO public.payment_receipts (id, receipt_number, daily_log_id, rider_id, bike_id, amount, currency, issued_at)
VALUES
    ('77777777-7777-7777-7777-777777777001', 'RCP-20261120-001', '66666666-6666-6666-6666-666666666001', '44444444-4444-4444-4444-444444444001', '55555555-5555-5555-5555-555555555001', 25000.00, 'SLE', NOW() - INTERVAL '4 days'),
    ('77777777-7777-7777-7777-777777777002', 'RCP-20261121-002', '66666666-6666-6666-6666-666666666002', '44444444-4444-4444-4444-444444444001', '55555555-5555-5555-5555-555555555001', 25000.00, 'SLE', NOW() - INTERVAL '3 days'),
    ('77777777-7777-7777-7777-777777777003', 'RCP-20261122-003', '66666666-6666-6666-6666-666666666003', '44444444-4444-4444-4444-444444444001', '55555555-5555-5555-5555-555555555001', 25000.00, 'SLE', NOW() - INTERVAL '2 days'),
    ('77777777-7777-7777-7777-777777777004', 'RCP-20261122-004', '66666666-6666-6666-6666-666666666004', '44444444-4444-4444-4444-444444444002', '55555555-5555-5555-5555-555555555002', 15000.00, 'SLE', NOW() - INTERVAL '2 days'),
    ('77777777-7777-7777-7777-777777777005', 'RCP-20261123-005', '66666666-6666-6666-6666-666666666005', '44444444-4444-4444-4444-444444444002', '55555555-5555-5555-5555-555555555002', 15000.00, 'SLE', NOW() - INTERVAL '1 day'),
    ('77777777-7777-7777-7777-777777777006', 'RCP-20261123-006', '66666666-6666-6666-6666-666666666006', '44444444-4444-4444-4444-444444444002', '55555555-5555-5555-5555-555555555002', 15000.00, 'SLE', NOW() - INTERVAL '18 hours'),
    ('77777777-7777-7777-7777-777777777007', 'RCP-20261123-007', '66666666-6666-6666-6666-666666666007', '44444444-4444-4444-4444-444444444004', '55555555-5555-5555-5555-555555555004', 25000.00, 'SLE', NOW() - INTERVAL '12 hours'),
    ('77777777-7777-7777-7777-777777777008', 'RCP-20261124-008', '66666666-6666-6666-6666-666666666008', '44444444-4444-4444-4444-444444444004', '55555555-5555-5555-5555-555555555004', 25000.00, 'SLE', NOW() - INTERVAL '2 hours'),
    ('77777777-7777-7777-7777-777777777009', 'RCP-20261123-009', '66666666-6666-6666-6666-666666666009', '44444444-4444-4444-4444-444444444005', '55555555-5555-5555-5555-555555555005', 25000.00, 'SLE', NOW() - INTERVAL '15 hours'),
    ('77777777-7777-7777-7777-777777777010', 'RCP-20261120-010', '66666666-6666-6666-6666-666666666010', '44444444-4444-4444-4444-444444444006', '55555555-5555-5555-5555-555555555006', 100000.00, 'SLE', NOW() - INTERVAL '5 days')
ON CONFLICT (receipt_number) DO NOTHING;

-- 8. SEED SAFETY INSPECTIONS
INSERT INTO public.safety_inspections (id, inspection_code, bike_id, rider_id, inspector_profile_id, brakes_ok, lights_ok, tires_ok, helmet_gear_ok, status, remarks, inspected_at, expires_at)
VALUES
    ('88888888-8888-8888-8888-888888888001', 'INSP-202611-001', '55555555-5555-5555-5555-555555555001', '44444444-4444-4444-4444-444444444001', '33333333-3333-3333-3333-333333333002', true, true, true, true, 'PASSED', 'Full mechanical inspection passed. Dual safety helmets verified.', NOW() - INTERVAL '10 days', NOW() + INTERVAL '80 days'),
    ('88888888-8888-8888-8888-888888888002', 'INSP-202611-002', '55555555-5555-5555-5555-555555555002', '44444444-4444-4444-4444-444444444002', '33333333-3333-3333-3333-333333333002', true, false, false, true, 'FLAGGED', 'Worn rear tyre tread and defective tail indicator. Immediate repair required.', NOW() - INTERVAL '2 days', NOW() + INTERVAL '7 days'),
    ('88888888-8888-8888-8888-888888888003', 'INSP-202611-003', '55555555-5555-5555-5555-555555555003', '44444444-4444-4444-4444-444444444003', '33333333-3333-3333-3333-333333333002', true, true, true, true, 'PASSED', 'Brand new motorcycle inspection passed at Lumley.', NOW() - INTERVAL '5 days', NOW() + INTERVAL '85 days'),
    ('88888888-8888-8888-8888-888888888004', 'INSP-202611-004', '55555555-5555-5555-5555-555555555004', '44444444-4444-4444-4444-444444444004', '33333333-3333-3333-3333-333333333002', true, true, true, true, 'PASSED', 'Passed periodic inspection at Kissy Road Station.', NOW() - INTERVAL '15 days', NOW() + INTERVAL '75 days'),
    ('88888888-8888-8888-8888-888888888005', 'INSP-202611-005', '55555555-5555-5555-5555-555555555006', '44444444-4444-4444-4444-444444444006', '33333333-3333-3333-3333-333333333002', true, true, true, true, 'PASSED', 'Congo Cross safety check approved.', NOW() - INTERVAL '20 days', NOW() + INTERVAL '70 days')
ON CONFLICT (inspection_code) DO NOTHING;

-- 9. SEED STATION PERMITS
INSERT INTO public.station_permits (id, permit_code, bike_id, rider_id, zone_id, permit_type, issued_date, expiry_date, fee_amount, status)
VALUES
    ('99999999-9999-9999-9999-999999999001', 'PMT-2026-LMJ-001', '55555555-5555-5555-5555-555555555001', '44444444-4444-4444-4444-444444444001', '11111111-1111-1111-1111-111111111001', 'ANNUAL_OPERATIONAL', CURRENT_DATE - 60, CURRENT_DATE + 305, 100000.00, 'ACTIVE'),
    ('99999999-9999-9999-9999-999999999002', 'PMT-2026-CTR-002', '55555555-5555-5555-5555-555555555002', '44444444-4444-4444-4444-444444444002', '11111111-1111-1111-1111-111111111006', 'ANNUAL_OPERATIONAL', CURRENT_DATE - 45, CURRENT_DATE + 320, 100000.00, 'ACTIVE'),
    ('99999999-9999-9999-9999-999999999003', 'PMT-2026-CCX-003', '55555555-5555-5555-5555-555555555006', '44444444-4444-4444-4444-444444444006', '11111111-1111-1111-1111-111111111005', 'ANNUAL_OPERATIONAL', CURRENT_DATE - 5, CURRENT_DATE + 360, 100000.00, 'ACTIVE')
ON CONFLICT (permit_code) DO NOTHING;

-- 10. SEED COMPLIANCE DISPUTES / APPEALS
INSERT INTO public.compliance_disputes (id, ticket_code, rider_id, bike_id, daily_log_id, subject, description, status, resolution_notes, created_at)
VALUES
    ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01', 'DISP-2026-001', '44444444-4444-4444-4444-444444444002', '55555555-5555-5555-5555-555555555002', '66666666-6666-6666-6666-666666666005', 'Safety Fine Appeal: Helmet Clip Was Intact', 'Rider states passenger helmet strap was functional and collector misjudged at Central Station.', 'IN_REVIEW', 'Inspector Alpha Sesay scheduled for re-examination.', NOW() - INTERVAL '1 day'),
    ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa02', 'DISP-2026-002', '44444444-4444-4444-4444-444444444001', '55555555-5555-5555-5555-555555555001', NULL, 'Levy Double Deduction Query', 'Inquiring regarding system sync of Orange Money levy payment.', 'RESOLVED', 'Ledger verified and receipt RCP-20261121-002 credited successfully.', NOW() - INTERVAL '3 days')
ON CONFLICT (ticket_code) DO NOTHING;

-- 11. SEED UNION ANNOUNCEMENTS
INSERT INTO public.union_announcements (id, title, message, zone_id, priority, published_by_profile_id, published_at)
VALUES
    ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb01', 'SDG 11 Road Safety Campaign Launch', 'All commercial riders across Freetown are reminded that helmet compliance for both rider and passenger is mandatory. Station marshals will enforce zero-tolerance starting Monday.', NULL, 'HIGH', '33333333-3333-3333-3333-333333333003', NOW() - INTERVAL '2 days'),
    ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb02', 'Digital Payment Gateway Adoption', 'TransitFlow SL in-app levy collection is now live at Lumley Junction, Central Station, and Kissy Road. Avoid cash leakage and request your instant digital receipt.', '11111111-1111-1111-1111-111111111001', 'NORMAL', '33333333-3333-3333-3333-333333333001', NOW() - INTERVAL '1 day'),
    ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb03', 'Annual Permit Renewal Grace Period', 'Executive committee extends 2026-2027 annual station permit renewal grace period through end of next month.', NULL, 'NORMAL', '33333333-3333-3333-3333-333333333003', NOW() - INTERVAL '6 hours')
ON CONFLICT (id) DO NOTHING;

-- 12. SEED NOTIFICATIONS
INSERT INTO public.notifications (id, recipient_profile_id, title, body, category, is_read, created_at)
VALUES
    ('cccccccc-cccc-cccc-cccc-cccccccccc01', '33333333-3333-3333-3333-333333333004', 'Daily Levy Payment Recorded', 'Your payment of Le 25,000.00 has been verified under receipt RCP-20261122-003.', 'PAYMENT', true, NOW() - INTERVAL '2 days'),
    ('cccccccc-cccc-cccc-cccc-cccccccccc02', '33333333-3333-3333-3333-333333333004', 'Safety Inspection Passed', 'Your bike BKE-101 has PASSED roadworthiness inspection. Valid for 90 days.', 'INSPECTION', false, NOW() - INTERVAL '10 days'),
    ('cccccccc-cccc-cccc-cccc-cccccccccc03', '33333333-3333-3333-3333-333333333005', 'Inspection Flagged - Action Required', 'Bike BKE-202 flagged for rear tyre tread and tail indicator. Please visit an inspector.', 'INSPECTION', false, NOW() - INTERVAL '2 days'),
    ('cccccccc-cccc-cccc-cccc-cccccccccc04', '33333333-3333-3333-3333-333333333006', 'Welcome to TransitFlow SL', 'Welcome Ibrahim Bah! Your rider profile R003 is active with TVS Star (BKE-103).', 'GENERAL', true, NOW() - INTERVAL '10 days')
ON CONFLICT (id) DO NOTHING;

-- 13. SEED AUDIT TRAIL LOGS
INSERT INTO public.audit_trail_logs (id, actor_profile_id, action, table_name, record_id, details, created_at)
VALUES
    ('dddddddd-dddd-dddd-dddd-dddddddddd01', '33333333-3333-3333-3333-333333333001', 'SYSTEM_INITIALIZE', 'system', 'transitflow_sl', '{"version": "2.0.0", "target": "Sierra Leone Okada Union"}'::jsonb, NOW() - INTERVAL '60 days'),
    ('dddddddd-dddd-dddd-dddd-dddddddddd02', '33333333-3333-3333-3333-333333333001', 'PROCESS_PAYMENT', 'daily_logs', '66666666-6666-6666-6666-666666666001', '{"amount": 25000, "plate": "BKE-101", "log_code": "LOG-20261120-001"}'::jsonb, NOW() - INTERVAL '4 days'),
    ('dddddddd-dddd-dddd-dddd-dddddddddd03', '33333333-3333-3333-3333-333333333002', 'RECORD_INSPECTION', 'safety_inspections', '88888888-8888-8888-8888-888888888002', '{"status": "FLAGGED", "plate": "BKE-202"}'::jsonb, NOW() - INTERVAL '2 days')
ON CONFLICT (id) DO NOTHING;
