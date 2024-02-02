/*
CASE 03: Foodie-Fi - Case Study A: Customer Journey

    All the info about this Case is in: https://8weeksqlchallenge.com/case-study-3/
*/

--CUSTOMER JOURNEY:

--Based off the 8 sample customers provided in the sample subscriptions table below, write a brief description about each customer’s onboarding journey.

    SELECT  sub.customer_id, sub.plan_id, pl.plan_name, sub.start_date
    FROM plans AS pl
    JOIN subscriptions AS sub ON pl.plan_id = sub.plan_id
    WHERE sub.customer_id IN (1,2,11,13,15,16,18,19)
    ORDER BY sub.customer_id, sub.start_date;

/*
Results:

        Client 1: Started on 2020-08-01 with a free trial and 7 days later upgrades to monthly basic plan.

        Client 2: Started on 2020-09-20 with a free trial and 7 days later upgrades to annual pro plan.

        Client 11: Started on 2020-11-19 with a free trial and churn when it ended.

        Client 13: Started on 2020-12-15 with a free trial, 7 days later  upgraded to basic monthly and on 2121-03-29 upgraded to pro monthly.

        Client 15: Started on 2020-03-17 with a free trial, 7 days later upgraded to pro monthly and an 2020-04-29 churn.
        
        Client 16: Started on 2020-05-31 with a free trial, 7 days later upgraded to basic monthly and an 2020-10-21 upgraded to pro annual plan..

        Client 18: Started on 2020-07-06 with a free trial, 7 days later upgraded to pro monthly.

        Client 19: Started on 2020-06-22 with a free trial, 7 days later upgraded to pro monthly and an 2020-08-29 upgraded to pro annual plan.
    */
    
