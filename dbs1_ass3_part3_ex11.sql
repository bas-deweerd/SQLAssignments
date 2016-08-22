-- 1 Attribute constraint: a president's party should be in 
-- {'DEMOCRATIC', 'REPUBLIC', 'WHIG', 'FEDERALIST', 'DEMO-REP'}
ALTER TABLE president
ADD CONSTRAINT check_party 
	CHECK (party IN ('DEMOCRATIC', 'REPUBLICAN', 'WHIG', 'FEDERALIST', 'DEMO-REP'));

	--test
	INSERT INTO president
	VALUES (44, 'OBAMA B', 1961, 6, 89,'SOCIALIST', 34);


-- 2 Tuple constraint: for all presidents born after 1800, 
-- the party can never be 'WHIG'
ALTER TABLE president
ADD CONSTRAINT never_WHIG_if_born_after_1800
	CHECK (party <> 'WHIG' OR birth_year <= 1800);

	--test
	INSERT INTO president
	VALUES (45, 'ADAMS J', 1801, 5, 90, 'WHIG', 38);


-- 3 Tuple constraints: for all marriages applies that if the spouse age is
-- higher than 60, then the number of children is zero.					

ALTER TABLE pres_marriage
 ADD CHECK(
  (spouse_age > 60 AND nr_children = 0) OR
  (spouse_age <= 60));
	
	--test
	INSERT INTO pres_marriage
	VALUES (43, 'FIRSTNAME LASTNAME', 65, 1, 1920);

-- 4 Tuple contraints: for all marriages applies that if the marriage year
-- is before 1800 then the president's age should be equal to or higher than 
-- 21 and if the marriage year is in or after 1800 then the president's age 
-- should be equal to or higher than 18.						

-- This assignment cannot be completed.


ALTER TABLE president
ADD CONSTRAINT check_marriage_year_with_president_age_21
	CHECK (marriage_year < 1800 OR pres_age >= 21),
ADD CONSTRAINT check_marriage_year_with_president_age_18
	CHECK (marriage_year >= 1800 OR pres_age >= 18);

	--test