/*Empiezo el análisis con el dataset daily_activity*/
SELECT *
FROM 	daily_activity
ORDER BY Id, ActivityDate;


/*Prueba de la columna Weekday*/
SELECT 
	Id, ActivityDate, TotalSteps, 
	strftime('%w', ActivityDate) AS Weekday
FROM  daily_activity;


/*Promedio de pasos por cada día de la semana*/
SELECT
	CASE strftime('%w', ActivityDate)
		WHEN '0' THEN 'Domingo'
		WHEN '1' THEN 'Lunes'
		WHEN '2' THEN 'Martes'
		WHEN '3' THEN 'Miércoles'
		WHEN '4' THEN 'Jueves'
		WHEN '5' THEN 'Viernes'						
		WHEN '6' THEN 'Sábado'
		END AS Weekday,
	 ROUND(AVG(TotalSteps), 2) AS Avg_Steps
FROM 
	daily_activity
GROUP BY
	Weekday
ORDER BY strftime('%w', ActivityDate);
/*No se observa ningún patron en particular. El día con mas cantidad de pasos es el sábado (fin de semana), pero es seguido por 
miércoles y jueves (dias de semana)*/


SELECT
	Id, 
	ROUND(AVG(VeryActiveMinutes), 2) AS "AvgVeryActive", 
	ROUND(AVG(FairlyActiveMinutes), 2) AS "AvgFairlyActive", 
	ROUND(AVG(LightlyActiveMinutes), 2) AS "AvgLightlyActive", 
	ROUND(AVG(SedentaryMinutes), 2) AS "AvgSedentary",
	ROUND(AVG(TotalSteps), 2) AS "AvgSteps",
	ROUND(AVG(Calories), 2) AS "AvgCalories"
FROM 
	daily_activity
GROUP BY Id
ORDER BY AvgVeryActive DESC;



/*Very active vs Calories*/
SELECT
	Calories, VeryActiveMinutes
FROM
	daily_activity
ORDER BY
	Calories DESC, VeryActiveMinutes DESC;
	
/*Se detectó que la persona que mas calorías quemó en un día tuvo solo 11 minutos muy activos,
 a diferencia del resto que tuvieron >100 minutos muy activos.*/
SELECT 
	*
FROM 
	daily_activity
WHERE 
	Calories = 4900;
/*Realizó 20000 pasos*/
	
/*Calories vs Total Steps*/
SELECT
	Calories, TotalSteps
FROM
	daily_activity
ORDER BY
	Calories DESC, TotalSteps DESC;
/* Nada explícito, pero parece haber un poco más de relación entre las calorías y los pasos que entre las calorías
y los minutos muy activos. Esto se podrá ver mejor visualizado*/


	
/* Longitud de los pasos vs Calorias quemadas.*/
SELECT
	Calories, ROUND((TotalDistanceKm*1000)/TotalSteps, 2) AS  StepDistance_m
FROM 
	daily_activity
WHERE
	StepDistance_m IS NOT NULL
ORDER BY 1 DESC;
/*Suponiendo que los pasos mas largos podrían sugerir que la persona corrió, se observa que la gran mayoría de registros
que con alrededor de 3000 calorías tienen una longitud de paso mayor a 1.2 metros. Mientras que el 
resto de registros ronda entre 1 y 1.2 metros*/


/*¿Las personas más activas son menos sedentarias?*/
SELECT
	Id,
	ROUND(AVG(VeryActiveMinutes), 2) AS "AvgVeryActiveMinutes",
	ROUND(AVG(SedentaryMinutes), 2) AS "AvgSedentaryMinutes"
FROM
	daily_activity
GROUP BY Id
ORDER BY AvgVeryActiveMinutes DESC, AvgSedentaryMinutes DESC;
/*No parece haber una correlación fuerte, son dos aspectos que pueden coexistir*/


/*Inclusión del dataset sleep_day*/
SELECT
	sleep_day.Id,
	ActivityDate AS Date,
	TotalSteps,
	TotalDistanceKm,
	VeryActiveMinutes,
	LightlyActiveMinutes,
	SedentaryMinutes,
	Calories,
	TotalMinutesAsleep 
FROM 
	daily_activity
JOIN
	sleep_day ON sleep_day.Id = daily_activity.Id AND
								sleep_day.SleepDay = daily_activity.ActivityDate;
								

/*Top 20 registros con MÁS horas de sueño*/
SELECT
	VeryActiveMinutes,
	SedentaryMinutes,
	Calories,
	TotalMinutesAsleep
FROM 
	daily_activity
JOIN
	sleep_day ON sleep_day.Id = daily_activity.Id AND
								sleep_day.SleepDay = daily_activity.ActivityDate
ORDER BY TotalMinutesAsleep DESC
LIMIT 20;
/*Pocas horas de sedentarismo*/

/*Top 20 registros con MENOS horas de sueño*/
SELECT
	VeryActiveMinutes,
	SedentaryMinutes,
	Calories,
	TotalMinutesAsleep
FROM 
	daily_activity
JOIN
	sleep_day ON sleep_day.Id = daily_activity.Id AND
								sleep_day.SleepDay = daily_activity.ActivityDate
ORDER BY TotalMinutesAsleep ASC
LIMIT 20;
/*Muchas horas de sedentarismo*/
/*En ninguno de los dos casos se detectan numerosos registros con actividad física intensa*/


/*Registros con la cantidad de horas de sueño recomendada para adultos (7-9 horas)*/
SELECT
	VeryActiveMinutes,
	SedentaryMinutes,
	Calories,
	TotalMinutesAsleep
FROM 
	daily_activity
JOIN
	sleep_day ON sleep_day.Id = daily_activity.Id AND
								sleep_day.SleepDay = daily_activity.ActivityDate
WHERE
	TotalMinutesAsleep BETWEEN 420 AND 540;
/*En este caso hay bastantes registros con actividad física intensa, aunque tampoco sean la inmensa mayoría*/


/*Actividad física intensa vs horas de sueño*/
SELECT
	VeryActiveMinutes,
	TotalMinutesAsleep
FROM 
	daily_activity
JOIN
	sleep_day ON sleep_day.Id = daily_activity.Id AND
								sleep_day.SleepDay = daily_activity.ActivityDate
ORDER BY
	VeryActiveMinutes DESC;
/*Se observa que la mayoría de registros con muchas horas de actividad física cuentan con una cantidad
horas de sueño entre 350 y 550 minutos, es decir, aproximadamente de 6 a 9 horas.*/



/*Minutos extras en la cama*/
SELECT
	TotalTimeInBed - TotalMinutesAsleep AS BedExtraMinutes,
	TotalMinutesAsleep,
	VeryActiveMinutes,
	SedentaryMinutes,
	TotalSteps
FROM
	daily_activity
JOIN
	sleep_day ON sleep_day.Id = daily_activity.Id AND
	                            sleep_day.SleepDay = daily_activity.ActivityDate
ORDER BY BedExtraMinutes DESC;
/*Si bien no es un patrón muy marcado, los registros con menos de 15 minutos extra en la cama, suelen tener más 
actividad física intensa, pero también más minutos de sedentarismo (luego de levantarse de la cama)*/


/*Promedio de horas dormidas por cantidad de registros de sueño en un día*/
SELECT
	TotalSleepRecords,
	ROUND(AVG(TotalMinutesAsleep), 2) AS AvgMinutesAsleep
FROM
	sleep_day
GROUP BY TotalSleepRecords;
/*Como era de esperarse, mientras más registros de sueño hay en un día, mas horas se duerme en promedio*/


/*Actividad física respecto a la cantidad de registros de sueño en un día*/
SELECT
	TotalSleepRecords,
	ROUND(AVG(VeryActiveMinutes), 2) AS AvgVeryActiveMinutes,
	ROUND(AVG(SedentaryMinutes), 2) AS AvgSedentaryMinutes
FROM
	daily_activity
JOIN
	sleep_day ON sleep_day.Id = daily_activity.Id AND
	                            sleep_day.SleepDay = daily_activity.ActivityDate
GROUP BY TotalSleepRecords;
/*Mientras menos cantidad de sueños se registran en un día, hay más minutos de actividad física intensa y también más
minutos de sedentarismo.*/






