Consider the following relations for a Flight Ticket Reservation application
PASSENGER(PID, NAME)
FLIGHT(FNO, ATYPE, FNAME,SOURCE,DESTINATION)
TICKET(TID, FNO,PID,DATE)
The primary keys are underlined. ATYPE can take two values (‘I’- International, ‘D’-Domestic). Create the
relations with given primary key and suitable foreign key constraints and insert suitable records into them.

A) Write the queries for the following specifications: (20)
➢List the details of passengers who travelled in a particular flight on a specified date. (5)
SELECT p.*
FROM passenger p
JOIN ticket t ON p.pid = t.pid
WHERE t.fno = <specified_flight_number>
AND t.tdate = TO_DATE('<specified_date>', 'dd-MON-yyyy');

➢List the flight details which has same source and destination 
SELECT *
FROM flight
WHERE source = destination;

➢Delete the ticket booked by a particular passenger given his/her name(5)
DELETE FROM ticket
WHERE pid IN (SELECT pid FROM passenger WHERE name = '<specified_passenger_name>');

➢Add column TicketFare to the FLIGHT table and assign default value of 1500 to it.(5)
ALTER TABLE flight ADD (TicketFare NUMBER(10) DEFAULT 1500);

B) Develop a trigger for preventing inserting ticket bookings for the dates before the system date.(15)
CREATE OR REPLACE TRIGGER prevent_past_date_booking
BEFORE INSERT ON ticket
FOR EACH ROW
BEGIN
  IF :new.tdate < TRUNC(SYSDATE) THEN
    RAISE_APPLICATION_ERROR(-20001, 'Cannot book tickets for past dates.');
  END IF;
END;
/


A) Write the queries for the following specifications: 
➢List the passenger details who has the maximum number of travel to ‘Chennai’ 
SELECT p.pid, p.name
FROM passenger p
JOIN ticket t ON p.pid = t.pid
JOIN flight f ON t.fno = f.fno
WHERE f.destination = 'CHENNAI'
GROUP BY p.pid, p.name
HAVING COUNT(*) = (
  SELECT MAX(travel_count)
  FROM (
    SELECT COUNT(*) AS travel_count
    FROM ticket t
    JOIN flight f ON t.fno = f.fno
    WHERE f.destination = 'CHENNAI'
    GROUP BY t.pid
  )
);

➢List the details of flight which has minimum bookings on a date. 
SELECT f.*
FROM flight f
LEFT JOIN ticket t ON f.fno = t.fno
WHERE t.tdate = DATE '2023-05-20' -- Replace with the desired date
GROUP BY f.fno, f.atype, f.fname, f.source, f.destination
HAVING COUNT(t.tid) = (
  SELECT MIN(booking_count)
  FROM (
    SELECT COUNT(*) AS booking_count
    FROM ticket
    WHERE tdate = DATE '2023-05-20' -- Replace with the desired date
    GROUP BY fno
  )
);

➢Delete the tickets of a particular flight name on a given date
DELETE FROM ticket
WHERE fno = (
  SELECT fno
  FROM flight
  WHERE fname = 'SPICE JET' -- Replace with the desired flight name
)
AND tdate = DATE '2023-05-18'; -- Replace with the desired date

B) Write a PL/SQL CURSOR block to display the passenger details travelling in a flight on a particular
date.(20)
DECLARE
  CURSOR c_passenger_details IS
    SELECT p.*
    FROM passenger p
    JOIN ticket t ON p.pid = t.pid
    WHERE t.fno = 322 -- Replace with the desired flight number
      AND t.tdate = DATE '2023-05-18'; -- Replace with the desired date
BEGIN
  FOR passenger_rec IN c_passenger_details LOOP
    DBMS_OUTPUT.PUT_LINE('Passenger ID: ' || passenger_rec.pid);
    DBMS_OUTPUT.PUT_LINE('Passenger Name: ' || passenger_rec.name);
    -- Add additional fields to display as needed
  END LOOP;
END;
/


(15)
A) Write the queries for the following specifications:
➢List details of Passengers who travelled on Monday. 
SELECT p.*
FROM passenger p
JOIN ticket t ON p.pid = t.pid
WHERE TO_CHAR(t.tdate, 'DAY') = 'MONDAY';

➢List the details of Passenger who booked in Domestic flights 
SELECT p.*
FROM passenger p
JOIN ticket t ON p.pid = t.pid
JOIN flight f ON t.fno = f.fno
WHERE f.ATYPE = 'D';

➢Add check constraint to the Flight table so that Source ≠ Destination 
ALTER TABLE flight
ADD CONSTRAINT check_source_destination
CHECK (source <> destination);
B) Write a function/procedure which returns the available number of tickets for a particular flight name
passed as input (20)
CREATE OR REPLACE FUNCTION get_available_tickets(p_flight_name VARCHAR2) RETURN NUMBER IS
  v_flight_count NUMBER;
  v_ticket_count NUMBER;
BEGIN
  SELECT COUNT(*) INTO v_flight_count
  FROM flight
  WHERE fname = p_flight_name;
  
  SELECT COUNT(*) INTO v_ticket_count
  FROM ticket
  JOIN flight ON ticket.fno = flight.fno
  WHERE flight.fname = p_flight_name;
  
  RETURN v_flight_count - v_ticket_count;
END;
/

SELECT get_available_tickets('SPICE JET') FROM dual;

 (15)
A) Write the queries for the following specifications: 
➢List the flight details which has the highest bookings on a particular date 
SELECT f.*
FROM flight f
JOIN (
  SELECT t.fno, COUNT(*) AS booking_count
  FROM ticket t
  WHERE t.tdate = TO_DATE('2023-05-20', 'YYYY-MM-DD')
  GROUP BY t.fno
  HAVING COUNT(*) = (
    SELECT MAX(booking_count)
    FROM (
      SELECT COUNT(*) AS booking_count
      FROM ticket
      WHERE tdate = TO_DATE('2023-05-20', 'YYYY-MM-DD')
      GROUP BY fno
    )
  )
) max_bookings ON f.fno = max_bookings.fno;

➢Give the Passenger details who have travelled during the last week of September in each year.
SELECT p.*
FROM passenger p
JOIN ticket t ON p.pid = t.pid
WHERE TO_CHAR(t.tdate, 'MM') = '09'
  AND TO_CHAR(t.tdate, 'IW') = TO_CHAR(TRUNC(SYSDATE, 'YYYY'), 'IW') - 1;

➢Give the source and destination of all the International flights 
SELECT f.source, f.destination
FROM flight f
WHERE f.ATYPE = 'I';

➢Postpone the travel of a passenger for a particular flight in the next days flight 
UPDATE ticket
SET tdate = tdate + 1
WHERE pid = <passenger_id>
  AND fno = <flight_number>
  AND tdate = TO_DATE('2023-05-20', 'YYYY-MM-DD');

B) Write a trigger to store the details of cancelled tickets in a temporary table with the timestamp 
-- Create the temporary table to store canceled tickets
CREATE TABLE canceled_tickets (
  tid NUMBER(10),
  fno NUMBER(10),
  pid NUMBER(10),
  tdate DATE,
  cancel_timestamp TIMESTAMP
);

-- Create the trigger
CREATE OR REPLACE TRIGGER ticket_cancel_trigger
AFTER DELETE ON ticket
FOR EACH ROW
BEGIN
  INSERT INTO canceled_tickets (tid, fno, pid, tdate, cancel_timestamp)
  VALUES (:old.tid, :old.fno, :old.pid, :old.tdate, SYSTIMESTAMP);
END;
/

. (15)
A) Write the queries for the following specifications: 
➢List all the passenger details who are travelling on the same date.
SELECT p.*
FROM passenger p
JOIN ticket t ON p.pid = t.pid
WHERE t.tdate = DATE '2023-05-20'; -- Replace with the desired date

➢Get the name of the city from which the highest number of passengers are starting. 
SELECT f.source, COUNT(*) AS passenger_count
FROM flight f
JOIN ticket t ON f.fno = t.fno
GROUP BY f.source
ORDER BY passenger_count DESC
FETCH FIRST 1 ROWS ONLY;

➢Find the passenger names who have used the flights that starts from city ending with ‘ur’ 
SELECT p.name
FROM passenger p
JOIN ticket t ON p.pid = t.pid
JOIN flight f ON t.fno = f.fno
WHERE f.source LIKE '%ur';

B) Write a Cursor block to display the details of all flights from a given source and calculate tentative time
based on the distance to the destination. (usage of separate table with distances or assigning distance inside
the cursor itself) (20)
-- Assuming there is a distance table with distances between source and destination
CREATE TABLE distance (
  source VARCHAR2(50),
  destination VARCHAR2(50),
  distance NUMBER(10)
);

-- Example cursor block
DECLARE
  CURSOR flight_cursor IS
    SELECT f.fno, f.fname, d.distance,
           ROUND(d.distance / 500) AS tentative_time
    FROM flight f
    JOIN distance d ON f.source = d.source AND f.destination = d.destination
    WHERE f.source = 'Chennai'; -- Replace with the desired source city
  
  flight_rec flight_cursor%ROWTYPE;
BEGIN
  OPEN flight_cursor;
  
  -- Fetch and process the flight records
  LOOP
    FETCH flight_cursor INTO flight_rec;
    EXIT WHEN flight_cursor%NOTFOUND;
    
    -- Display flight details and tentative time
    DBMS_OUTPUT.PUT_LINE('Flight: ' || flight_rec.fno || ', ' || flight_rec.fname);
    DBMS_OUTPUT.PUT_LINE('Distance: ' || flight_rec.distance);
    DBMS_OUTPUT.PUT_LINE('Tentative Time: ' || flight_rec.tentative_time || ' hours');
    DBMS_OUTPUT.PUT_LINE('------------------------');
  END LOOP;
  
  CLOSE flight_cursor;
END;
/


 (15)
A) Write the queries for the following specifications: 
➢List the flights which has lowest bookings on a particular date 
SELECT f.fname, COUNT(*) AS booking_count
FROM flight f
LEFT JOIN ticket t ON f.fno = t.fno AND t.tdate = TO_DATE('2023-05-20', 'YYYY-MM-DD')
GROUP BY f.fname
HAVING COUNT(*) = (
  SELECT MIN(booking_count)
  FROM (
    SELECT f.fname, COUNT(*) AS booking_count
    FROM flight f
    LEFT JOIN ticket t ON f.fno = t.fno AND t.tdate = TO_DATE('2023-05-20', 'YYYY-MM-DD')
    GROUP BY f.fname
  )
);

➢Give the Passenger details who have travelled during the last two years.
SELECT p.pid, p.name
FROM passenger p
JOIN ticket t ON p.pid = t.pid
WHERE t.tdate >= ADD_MONTHS(TRUNC(SYSDATE, 'YYYY'), -24)

➢Create a distance table which contains distance between source and destination and display all the international flights with source and destination and relevant distance.
CREATE TABLE distance (
  source VARCHAR2(50),
  destination VARCHAR2(50),
  distance NUMBER(10, 2)
);

INSERT INTO distance (source, destination, distance)
VALUES ('USA', 'JAPAN', 7000);
-- Add more rows for other international flights and their distances

SELECT f.fname, f.source, f.destination, d.distance
FROM flight f
JOIN distance d ON f.source = d.source AND f.destination = d.destination
WHERE f.ATYPE = 'I';

➢Drop column no. of seats in flight table and add a column Seat No. and class in ticket.
ALTER TABLE flight DROP COLUMN no_of_seats;
ALTER TABLE ticket ADD seat_no VARCHAR2(10), ADD class VARCHAR2(10);

B) Develop a trigger for displaying suitable user messages on reserving and cancelling tickets. 
CREATE OR REPLACE TRIGGER ticket_changes
AFTER INSERT OR DELETE ON ticket
FOR EACH ROW
DECLARE
  v_message VARCHAR2(200);
BEGIN
  IF INSERTING THEN
    v_message := 'Ticket reserved successfully. Thank you for choosing our service.';
  ELSIF DELETING THEN
    v_message := 'Ticket cancelled successfully. We hope to see you again.';
  END IF;
  DBMS_OUTPUT.PUT_LINE(v_message);
END;
/

 (15)
A) Write the queries for the following specifications: 
➢Give the flight names which has highest bookings in the year 2017 
SELECT f.fname, COUNT(*) AS booking_count
FROM flight f
JOIN ticket t ON f.fno = t.fno
WHERE EXTRACT(YEAR FROM t.tdate) = 2017
GROUP BY f.fname
HAVING COUNT(*) = (
  SELECT MAX(booking_count)
  FROM (
    SELECT f.fname, COUNT(*) AS booking_count
    FROM flight f
    JOIN ticket t ON f.fno = t.fno
    WHERE EXTRACT(YEAR FROM t.tdate) = 2017
    GROUP BY f.fname
  )
);

➢Delete the bookings of a particular passenger booked after a given date.
DELETE FROM ticket
WHERE pid = 3
  AND tdate > TO_DATE('2022-01-01', 'YYYY-MM-DD');

➢Find the highest traveler of 2018. 
SELECT p.name, COUNT(*) AS travel_count
FROM passenger p
JOIN ticket t ON p.pid = t.pid
WHERE EXTRACT(YEAR FROM t.tdate) = 2018
GROUP BY p.name
HAVING COUNT(*) = (
  SELECT MAX(travel_count)
  FROM (
    SELECT p.name, COUNT(*) AS travel_count
    FROM passenger p
    JOIN ticket t ON p.pid = t.pid
    WHERE EXTRACT(YEAR FROM t.tdate) = 2018
    GROUP BY p.name
  )
);

➢Add a column ‘class’ to Flight and set constraint such that the field contains only “Business” or “
Economic”. Remove Date from Ticket and add Timestamp 
ALTER TABLE flight
ADD class VARCHAR2(10) CHECK (class IN ('Business', 'Economic'));

ALTER TABLE ticket
DROP COLUMN tdate;

ALTER TABLE ticket
ADD ttimestamp TIMESTAMP;

B) Write a trigger to prevent cancellation of tickets(deletion) from the Ticket table if the travel time is 10hrs
minimum ahead of time of canceling 
CREATE OR REPLACE TRIGGER prevent_ticket_cancellation
BEFORE DELETE ON ticket
FOR EACH ROW
DECLARE
  v_travel_time INTERVAL DAY(1) TO SECOND(0);
BEGIN
  -- Calculate the travel time between the cancellation time and the date of journey
  v_travel_time := NUMTODSINTERVAL(:OLD.d_o_j - SYSDATE, 'day');
  
  -- Prevent ticket cancellation if travel time is less than 10 hours
  IF v_travel_time < INTERVAL '10' HOUR THEN
    RAISE_APPLICATION_ERROR(-20001, 'Ticket cannot be cancelled as travel time is less than 10 hours');
  END IF;
END;
/

