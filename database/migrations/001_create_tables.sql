-- Enable UUID generation

CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Hotel Bookings Table

CREATE TABLE IF NOT EXISTS hotel_bookings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    org_id UUID NOT NULL,

    hotel_id VARCHAR(100) NOT NULL,

    city VARCHAR(100) NOT NULL,

    checkin_date DATE NOT NULL,

    checkout_date DATE NOT NULL,

    amount NUMERIC(12,2) NOT NULL,

    status VARCHAR(50) NOT NULL,

    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT valid_booking_dates
        CHECK (checkout_date > checkin_date),

    CONSTRAINT valid_booking_amount
        CHECK (amount >= 0)
);

-- Booking Events Table

CREATE TABLE IF NOT EXISTS booking_events (
    id BIGSERIAL PRIMARY KEY,

    booking_id UUID NOT NULL
        REFERENCES hotel_bookings(id)
        ON DELETE CASCADE,

    event_type VARCHAR(100) NOT NULL,

    payload JSONB,

    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Index for optimized hotel booking query

CREATE INDEX idx_hotel_bookings_city_created_org_status
ON hotel_bookings (
    city,
    created_at,
    org_id,
    status
)
INCLUDE (amount);

-- Index for booking event lookup

CREATE INDEX idx_booking_events_booking_id
ON booking_events (booking_id);

-- Index for recent booking events

CREATE INDEX idx_booking_events_created_at
ON booking_events (created_at);