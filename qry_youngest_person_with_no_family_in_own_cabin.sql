
-- find the youngest person travelling without any family and staying their own cabin
-- use only records where the data is complete for the passengers

-- method:
-- identify people with no family first
-- identify people no sharing a room
-- result = youngest person is actually a maid to another passenger

select top 1 *
from
vw_train_and_test_combined 
where cabin in (
					select cabin
					from
					vw_train_and_test_combined
					where cabin in
						(
							select cabin 
							from 
							vw_train_and_test_combined
							where parch = 0 and sibsp = 0
							and cabin is not null
						)
					group by cabin
					having count(cabin) = 1
		       )
and age is not null
order by age asc