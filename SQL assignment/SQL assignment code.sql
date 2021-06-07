--1 Αεροσκάφη που δεν έχουν κάνει καμιά πτήση [όλα τα στοιχεία του αεροσκάφους].
SELECT * FROM aircrafts
WHERE aircraft_code NOT IN(
SELECT aircraft_code FROM flights)

--2 Οι κρατήσεις που κόστισαν πάνω από 1 εκατομμύριο ρούβλια και αποτελούνται από 4 εισιτήρια και πάνω [book_ref, total_amount, πλήθος_εισιτηρίων].
SELECT book_ref,total_amount,COUNT(tickets)
FROM bookings JOIN tickets USING(book_ref)
WHERE total_amount > 1000000
GROUP BY book_ref HAVING COUNT(tickets) >3

--3 Το όνομα του επιβάτη ή επιβατών που έχουν κάνει την πιο πρόσφατη κράτηση [passenger_name, book_date].
SELECT passenger_name FROM bookings JOIN tickets USING(book_ref)
WHERE (book_date) IN (SELECT max(book_date) FROM bookings)

--4 Τα μοντέλα των αεροσκαφών που έχουν ακυρωμένες πτήσεις και από και προς το St. Petersburg [model].
SELECT DISTINCT model FROM aircrafts NATURAL JOIN flights_v
WHERE (status ='Cancelled' AND departure_city = 'St. Petersburg')
INTERSECT
SELECT DISTINCT model FROM aircrafts NATURAL JOIN flights_v
WHERE (status ='Cancelled' AND arrival_city= 'St. Petersburg')

--5 Τα ονόματα των επιβατών με εισητήριο business που έχουν πτήσεις μόνο προς τo Kursk [passenger_name].
SELECT passenger_name FROM tickets join ticket_flights USING(ticket_no) 
WHERE (fare_conditions = 'Business')
INTERSECT
SELECT passenger_name FROM tickets join ticket_flights USING(ticket_no) NATURAL JOIN flights_v
WHERE arrival_city IN (SELECT arrival_city FROM flights_v) AND fare_conditions = 'Business'
GROUP BY passenger_name
HAVING MAX(arrival_city) = 'Kursk' AND MIN(arrival_city) = 'Kursk'

--6 . Θέσεις αεροσκαφών για τις οποίες δεν έχει εκδοθεί ποτέ boarding pass [aircraft_code,seat_no].
SELECT aircraft_code,seat_no FROM seats
WHERE NOT EXISTS(SELECT seat_no FROM flights JOIN boarding_passes USING (flight_id)
WHERE seats.aircraft_code = flights.aircraft_code AND
seats.seat_no = boarding_passes.seat_no)

--7 Τυπώστε τα στοιχεία όλων των εισιτηρίων της κράτησης '070133' [ticket_no, flight_id,
--book_ref, book_date, total_amount, passenger_id, passenger_name, contact_data,
--fare_conditions, amount, boarding_no, seat_no]. Τα δυο τελευταία πεδία να εμφανίζονται μόνο
--αν έχει πραγματοποιηθεί η πτήση στην οποία αντιστοιχεί το εισιτήριο, αλλιώς να έχουν την
--τιμή NULL.
SELECT t.ticket_no, f.flight_id,
b.book_ref, book_date, total_amount, passenger_id, passenger_name, contact_data,
fare_conditions, amount, 
CASE WHEN status = 'Arrived' THEN boarding_no
END AS boarding_no, 
CASE WHEN status = 'Arrived' THEN seat_no
END AS seat_no
FROM tickets t JOIN bookings b ON b.book_ref = t.book_ref
JOIN ticket_flights tf ON tf.ticket_no = t.ticket_no
JOIN boarding_passes bp ON bp.ticket_no = tf.ticket_no
JOIN flights f ON f.flight_id = tf.flight_id
WHERE b.book_ref = '070133'

--8 Τυπώστε τα στοιχεία όλων των εισιτηρίων της κράτησης '070133' [ticket_no, flight_id,
--book_ref, book_date, total_amount, passenger_id, passenger_name, contact_data,
--fare_conditions, amount, boarding_no, seat_no]. Τα δυο τελευταία πεδία να εμφανίζονται μόνο
--αν έχει πραγματοποιηθεί η πτήση στην οποία αντιστοιχεί το εισιτήριο, αλλιώς να έχουν την
--τιμή NULL.
SELECT r1.departure_airport, r1.arrival_airport, r1.departure_city, r1.arrival_city, COUNT(*) FROM ROUTES r1
LEFT JOIN routes r2 ON r1.departure_airport = r2.arrival_airport
AND r1.arrival_airport = r2.departure_airport
AND r1.departure_airport > r2.arrival_airport
WHERE r2.departure_airport IS NULL AND r1.departure_airport <= r1.arrival_airport
GROUP BY r1.departure_airport, r1.arrival_airport, r1.departure_city, r1.arrival_city
HAVING COUNT(r1.flight_no) > 2
ORDER BY r1.departure_airport;

--9 Τα αεροσκάφη που έχουν πετάξει προς όλα τα αεροδρόμια πόλεων που αρχίζουν από 'Υ'[aircraft_code].
SELECT aircraft_code FROM aircrafts a
WHERE NOT EXISTS (SELECT * FROM flights_v fv
WHERE arrival_city LIKE 'Y%' AND status = 'Arrived' AND  NOT EXISTS (SELECT arrival_airport FROM flights_v fv2 
WHERE fv.arrival_airport = fv2.arrival_airport AND a.aircraft_code = fv2.aircraft_code));