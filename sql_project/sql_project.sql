/* Q1: Some of the facilities charge a fee to members, but some do not.
Please list the names of the facilities that do. */

SELECT
  f.name
  FROM country_club.Facilities f
  WHERE f.membercost > 0

/* Q2: How many facilities do not charge a fee to members? */

SELECT
  COUNT(*) AS no_memberfee_count
  FROM country_club.Facilities f
  WHERE f.membercost = 0

/* Q3: How can you produce a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost?
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */

SELECT
  facid
  ,name
  ,membercost
  ,monthlymaintenance
  FROM country_club.Facilities f
  WHERE f.membercost < (monthlymaintenance * 0.2)

/* Q4: How can you retrieve the details of facilities with ID 1 and 5?
Write the query without using the OR operator. */

SELECT
  *
  FROM country_club.Facilities f
  WHERE facid IN (1, 5)

/* Q5: How can you produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100? Return the name and monthly maintenance of the facilities
in question. */

SELECT
  name
  ,monthlymaintenance
  ,CASE WHEN monthlymaintenance > 100 THEN 'expensive' ELSE 'cheap' END AS maintenance_cost_category
  FROM country_club.Facilities

/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Do not use the LIMIT clause for your solution. */

SELECT
  firstname
  ,surname
  FROM country_club.Members
  WHERE joindate = (SELECT MAX(joindate) FROM country_club.Members)

/* Q7: How can you produce a list of all members who have used a tennis court?
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */

SELECT DISTINCT
  CONCAT(m.firstname, ' ', m.surname) AS member_name
  ,f.name AS facility_name
  FROM country_club.Bookings b
  LEFT JOIN country_club.Facilities f ON b.facid = f.facid
  LEFT JOIN country_club.Members m ON b.memid = m.memid
  WHERE f.name LIKE '%Tennis Court%'
  AND m.memid != 0 -- The question requests *members*, so guests are excluded
  ORDER BY member_name

/* Q8: How can you produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30? Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */

SELECT
  f.name AS facility_name
  ,CONCAT(m.firstname, ' ', m.surname) AS member_name

  -- If memid=0, then the user is a guest and should be charged guestcost * slots.
  -- Otherwise, the user is a member and should be charged membercost * slots
  ,(CASE WHEN m.memid = 0 THEN f.guestcost ELSE f.membercost END) * b.slots AS total_cost
  FROM country_club.Bookings b
  LEFT JOIN country_club.Facilities f ON b.facid = f.facid
  LEFT JOIN country_club.Members m ON b.memid = m.memid
  WHERE CAST(b.starttime AS DATE) = '2012-09-14'
  HAVING total_cost > 30
  ORDER BY total_cost DESC

/* Q9: This time, produce the same result as in Q8, but using a subquery. */

SELECT
  sub.name AS facility_name
  ,CONCAT(m.firstname, ' ', m.surname) AS member_name
  ,sub.total_cost
  FROM country_club.Bookings b
  LEFT JOIN country_club.Members m ON b.memid = m.memid
  LEFT JOIN (SELECT
             -- If memid=0, then the user is a guest and should be charged guestcost * slots.
             -- Otherwise, the user is a member and should be charged membercost * slots
             (CASE WHEN bo.memid = 0 THEN fa.guestcost ELSE fa.membercost END) * bo.slots AS total_cost
             ,fa.name
            FROM country_club.Bookings bo
            LEFT JOIN country_club.Facilities fa ON bo.facid = fa.facid) sub ON b.bookid = sub.bookid

  WHERE CAST(b.starttime AS DATE) = '2012-09-14'
  AND total_cost > 30
  ORDER BY total_cost DESC

/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */

SELECT
  sub.name AS facility_name
  ,SUM(sub.total_cost) as total_revenue
  FROM (SELECT
            -- If memid=0, then the user is a guest and should be charged guestcost * slots.
            -- Otherwise, the user is a member and should be charged membercost * slots
            (CASE WHEN bo.memid = 0 THEN fa.guestcost ELSE fa.membercost END) * bo.slots AS total_cost
            ,fa.name
            FROM country_club.Bookings bo
            LEFT JOIN country_club.Facilities fa ON bo.facid = fa.facid) sub

  GROUP BY sub.name
  HAVING total_revenue < 1000
  ORDER BY total_revenue
