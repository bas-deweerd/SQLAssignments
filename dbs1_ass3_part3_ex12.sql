-- 1 For all elections after 1960, the sum of all votes per election year 
-- has to be less than or equal to 538.						
create  trigger restrict_nr_votes
	after insert or update on election
	for each row execute procedure restrict_nr_votes();

create or replace function restrict_nr_votes()
	returns trigger as $$
begin
	if (new.election_year >1960) then
		 if((select SUM(votes) from election as elec where elec.election_year = election_year) > 538) then
		 raise exception 'Too many votes';
 end if;
end if;
return null;
end;
$$ language plpgsql;

	--test
	insert into election
	values (2012, 'FIRSTNAME LASTNAME', 1, 'L');

-- 2 The number of winners per election can only be 0 or 1.
create  trigger restrict_nr_winners
	after insert or update on election
	for each row execute procedure restrict_nr_winners();

create or replace function restrict_nr_winners()
	returns trigger as $$
begin
	if (new.winner_loser_indic = 'W' or new.winner_loser_indic = 'L') then
		if((select COUNT(winner_loser_indic) from election where winner_loser_indic = 'W') > 1) then
		raise exception 'There are too many winners.';
 end if;
end if;
return null;
end;
$$ language plpgsql;

	-- test
	insert into election
	values (1924, 'FIRSTNAME LASTNAME', 1, 'W');

-- 3 For all elections applies that if the number of votes is not equal to the 
-- maximum number of votes during an election, the candidate gets a winner_loser_indicator 'L'
create  trigger restrict_votes_loser
	after insert or update on election
	for each row execute procedure restrict_votes_loser();

create or replace function restrict_votes_loser()
	returns trigger as $$
begin
	if (new.winner_loser_indic = 'W') then
		if (new.votes != (select max(votes) from election where new.election_year = election_year) ) then
		update election set winner_loser_indic = 'L' where new.election_year = election_year and new.candidate = candidate;

end if;
end if;
return null;
end;
$$ language plpgsql;


-- 4 For all winners in the election table (winner_loser_indicator = 'W'), the 
-- number of votes is equal to the maximum number of votes during that election.
create  trigger restrict_votes_winner
	after insert or update on election
	for each row execute procedure restrict_votes_winner();

create or replace function restrict_votes_winner()
	returns trigger as $$
begin
	if (new.winner_loser_indic = 'L') then
		if (new.votes = (select max(votes) from election where new.election_year = election_year) ) then
		update election set winner_loser_indic = 'W' where new.election_year = election_year and new.candidate = candidate;

end if;
end if;
return null;
end;
$$ language plpgsql;



-- 5 For all presidents who married more than once applies that if his age at one
-- marriage is smaller than his age at another marriage, then the spouse age at his
-- one marriage is alsos smaller than the spouse age of the other marriage.
create  trigger restrict_married_age
	after insert or update of spouse_age on pres_marriage
	for each row execute procedure restrict_married_age();

create or replace function restrict_married_age()
	returns trigger as $$
begin
	if (new.spouse_age <= (select max(spouse_age) from pres_marriage where new.spouse_age = spouse_age)) then
	raise exception 'The spouse has to be older.';


end if;
return null;
end;
$$ language plpgsql;

	--test
	insert into pres_marriage
	values (1, 'FIRSTNAME LASTNAME', 22, 0, 1770);


-- 6 For all presidents born before 1800 applies that they don't have 
-- 'TOUCH FOOTBALL' as one of their hobbies.					DID NOT WORK CORRECTLY. WHY????
create  trigger restrict_hobby_president
	after insert or update of hobby on pres_hobby
	for each row execute procedure restrict_hobby_president();

create or replace function restrict_hobby_president()
	returns trigger as $$
begin
	if (new.hobby = 'TOUCH FOOTBALL') then 
	if (select hobby from pres_hobby where new.hobby = hobby and pres_id IN (select id from president where birth_year < 1800)) then
	raise exception 'Hobby can not be touch football';

end if;
end if;
return null;
end;
$$ language plpgsql;

	--test
	insert into pres_hobby
	values (1, 'TOUCH FOOTBALL');