-- Example seed for CONSUMABLE_STATUS when battery/filter show 0%.
-- Replace device_id with a value from SELECT device_id FROM "DEVICES";

INSERT INTO public."CONSUMABLE_STATUS" (
  device_id,
  filter_remaining_percent,
  battery_remaining_percent,
  scent_cartridge_remaining_percent,
  updated_at
)
VALUES (
  'YOUR_DEVICE_ID_HERE',
  80,
  60,
  100,
  now()
)
ON CONFLICT (device_id) DO UPDATE SET
  filter_remaining_percent = EXCLUDED.filter_remaining_percent,
  battery_remaining_percent = EXCLUDED.battery_remaining_percent,
  scent_cartridge_remaining_percent = EXCLUDED.scent_cartridge_remaining_percent,
  updated_at = EXCLUDED.updated_at;

-- Verify:
-- SELECT cs.* FROM "CONSUMABLE_STATUS" cs
-- JOIN "USER_DEVICES" ud ON ud.device_id = cs.device_id
-- WHERE ud.user_id = 'YOUR_USER_ID_HERE';
