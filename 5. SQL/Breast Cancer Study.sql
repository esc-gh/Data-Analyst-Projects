Use Project

select * from Breast_Cancer;

--change numbers into more meaningful words
update Breast_Cancer
set Class = replace(replace(class, '2', 'Benign'), '4', 'Malignant')

--hours lost trying to create a procedure or function to give averages of different columns
select Class, avg([Clump Thickness]) 'Average Clump Thickness', AVG([Uniformity of Cell Shape]) 'Avg Cell Shape' from Breast_Cancer
group by Class

--remove duplicates into a new table
select DISTINCT * into BC2 from Breast_Cancer

--know there are null values in Bare Nuclei from notes
select count(*) from Breast_Cancer
where [Bare Nuclei] is null

--replace with mode
--find mode
select [Bare Nuclei], count([Bare Nuclei]) as Count from BC2
group by [Bare Nuclei]
order by count(*) desc

--put into replace query
update BC2
set [Bare Nuclei] = (select top 1 [Bare Nuclei]
	from BC2
	group by [Bare Nuclei]
	order by count(*) desc)
where [Bare Nuclei] is null

--What percentages were Benign or Malignant?
--Function
create function ClassRate (@Class varchar(10))
returns table
as
return select round(((count(case when Class = @Class then 1 end)*1.00)
	/(count(Class)*1.00)), 2) as [Class Rate (%)] 
from BC2

-- Problems with number of decimal places
select * from ClassRate('Benign')

--Done more cleanly with a query, minor lack of decimal places
select Class, count(class) as [Class Count], round(count(class)*100/(select count(class) from BC2),2) as [Class %] from BC2
group by class

--Is there a link between uniformity of cell shape and size?
select [Uniformity of Cell Size], avg([Uniformity of Cell Shape]) 'Mean Cell Shape' into Shape_Mean from BC2
group by [Uniformity of Cell Size]
order by [Uniformity of Cell Size] asc

select * from Shape_Mean
order by [Cell Size] asc

--Frequency of size/shape combinations ordered by size then shape
select [Uniformity of Cell Size], [Uniformity of Cell Shape], count([Uniformity of Cell Shape]) as Count from BC2
group by [Uniformity of Cell Shape], [Uniformity of Cell Size]
order by [Uniformity of Cell Size] asc;

--Most frequent size/shape combinations
select [Uniformity of Cell Size], [Uniformity of Cell Shape], count([Uniformity of Cell Shape]) as Count from BC2
group by [Uniformity of Cell Size], [Uniformity of Cell Shape]
order by count(*) desc

--Much difficulty getting an output of the modal shape for each size
--Solved with ranks and multiple queries, run middle SELECT to demo
with average as
(
select
[Uniformity of Cell Size], [Uniformity of Cell Shape], count(*) as Counter,
Rank() over (
	partition by [Uniformity of Cell Size]
	order by count(*) desc) as rn
from BC2
group by [Uniformity of Cell Shape], [Uniformity of Cell Size])

select [Uniformity of Cell Size], [Uniformity of Cell Shape], Counter into Shape_Mode from average
where rn=1

select * from Shape_Mode

--Made a view of joined tables purely to demo, might make more sense to put it in a new table
create view Size_Shape as
select Mean.[Cell Size], Mean.[Mean Cell Shape], Mode.[Modal Cell Shape], Mode.Counter as [Modal Count] from Shape_Mean as Mean
inner join Shape_Mode as Mode
on Mean.[Cell Size] = Mode.[Cell Size]

select * from Size_Shape
order by [Cell Size] asc