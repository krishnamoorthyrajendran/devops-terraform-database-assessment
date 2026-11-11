-- Insert 200 hotel bookings

INSERT INTO hotel_bookings (
    id,
    org_id,
    hotel_id,
    city,
    checkin_date,
    checkout_date,
    amount,
    status,
    created_at
)
SELECT
    md5('booking-' || i)::uuid,

    md5('organization-' || ((i % 5) + 1))::uuid,

    'HOTEL-' || ((i % 20) + 1),

    (
        ARRAY[
            'delhi',
            'mumbai',
            'chennai',
            'bangalore',
            'coimbatore'
        ]
    )[1 + (i % 5)],

    CURRENT_DATE + (i % 30),

    CURRENT_DATE + (i % 30) + 2,

    (1000 + (i * 125))::numeric(12,2),

    (
        ARRAY[
            'confirmed',
            'cancelled',
            'pending',
            'completed'
        ]
    )[1 + (i % 4)],

    NOW() - ((i % 60) * INTERVAL '1 day')

FROM generate_series(1, 200) AS i;


-- Insert booking events for selected bookings

INSERT INTO booking_events (
    booking_id,
    event_type,
    payload,
    created_at
)
SELECT
    b.id,

    'booking_' || b.status,

    jsonb_build_object(
        'hotel_id', b.hotel_id,
        'city', b.city,
        'status', b.status,
        'amount', b.amount
    ),

    b.created_at + INTERVAL '1 hour'

FROM hotel_bookings b

WHERE mod(
    (
        SELECT count(*)
        FROM hotel_bookings b2
        WHERE b2.id <= b.id
    ),
    3
) = 0;


-- Display seed data statistics

SELECT COUNT(*) AS total_bookings
FROM hotel_bookings;

SELECT COUNT(*) AS total_events
FROM booking_events;

SELECT city, COUNT(*) AS booking_count
FROM hotel_bookings
GROUP BY city
ORDER BY city;

SELECT status, COUNT(*) AS booking_count
FROM hotel_bookings
GROUP BY status
ORDER BY status;