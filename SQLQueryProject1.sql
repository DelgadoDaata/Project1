--data validation
Select COLUMN_NAME, DATA_TYPE, IS_NULLABLE, CHARACTER_MAXIMUM_LENGTH
From INFORMATION_SCHEMA.COLUMNS
Where Table_name = 'population-and-demography F'

Select COLUMN_NAME, DATA_TYPE, IS_NULLABLE, CHARACTER_MAXIMUM_LENGTH
From INFORMATION_SCHEMA.COLUMNS
Where Table_name = 'population-and-demography M'

--Creating a view 
Create View newview As
Select
t1.Population As Population_Female,
t1.Entity As Entity_Female,
t1.Year As Year_Female,
t2.Population As Population_Male,
t2.Entity As Entity_Male,
t2.Year As Year_Male
From [population-and-demography F] t1
Join [population-and-demography M] t2
On t1.Id=t2.Id;

--Creating a Common Table Expression
With Total_Popu As(Select*,
Population_Female+Population_Male As Total_Population
From newview)

--loocking the percentage increment
Select *,
	Lag (Total_Population) Over (PARTITION BY Entity_Female Order By Entity_Female) As PreviousValue,
Case
	When Lag (Total_Population) Over (PARTITION BY Entity_Female Order By Entity_Female) Is Null Then Null
	Else ((Total_Population - Lag (Total_Population) Over (PARTITION BY Entity_Female Order By Entity_Female ))*100/ Lag (Total_Population) Over(PARTITION BY Entity_Female Order By Entity_Female)) 
	End As PercentageIncrement
From Total_Popu
ORDER BY Entity_Female desc


--looking for news births per year
With Total_Popu As(Select*,
	Population_Female+Population_Male As Total_Population
	From newview)

Select top 10*,
	Lag (Total_Population) Over (PARTITION BY Entity_Female Order By Entity_Female) As PreviousValue,
	Case
	when Lag (Total_Population) Over (PARTITION BY Entity_Female Order By Entity_Female) Is Null Then Null
	Else ((Total_Population - Lag (Total_Population) Over (PARTITION BY Entity_Female Order By Entity_Female ))) 
	End As Total_birth
From Total_Popu
ORDER BY Entity_Female

--People counting per year
Select Year_Female,
SUM(Population_Female+Population_Male) As Total_Population
From newview
where Year_Female=2023 and Year_Male=2023
Group by Year_Female

--Population growth
Select Entity_Female As Total_Entity,
((MAX(Population_Female+Population_Male)-MIN(Population_Female+Population_Male))/MIN(Population_Female+Population_Male))* 100 As Population_growth
From newview
Where Year_Female BETWEEN 2010 and 2020
Group by Entity_Female
Order by Population_growth Desc



