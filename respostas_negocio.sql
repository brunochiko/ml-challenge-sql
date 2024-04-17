/* RESPOSTA NEGÓCIO 1
Liste usuários com aniversário de hoje cujo número de vendas realizadas em janeiro de 2020 seja superior a 1500.
*/

SELECT 
	C.ID,
    C.EMAIL,
    C.BIRTHDATE,
    C.FIRSTNAME,
    C.LASTNAME,
    SUM(O.TOTALAMMOUNT) AS TOTAL
FROM 
	MELI.CUSTOMER C
    INNER JOIN MELI.ORDER O ON C.ID = O.SELLER 
WHERE 
	MONTH(C.BIRTHDATE) = MONTH(CURDATE()) AND DAY(C.BIRTHDATE) = DAY(CURDATE()) #CUSTOMERS CELEBRATING BIRTHDAY TODAY 
    AND MONTH(O.DATE) = 1 AND year(O.DATE) = 2024 #ONLY 202401 ORDERS 
GROUP BY 
	C.ID,
    C.EMAIL,
    C.FIRSTNAME,
    C.LASTNAME
HAVING SUM(O.TOTALAMMOUNT) >= 1500; # TOTAL ORDERS OVER 1500

/* RESPOSTA NEGÓCIO 2
Para cada mês de 2020, são solicitados os 5 principais usuários que mais venderam (R$) na categoria Celulares. São obrigatórios o mês e ano da análise, 
nome e sobrenome do vendedor, quantidade de vendas realizadas, quantidade de produtos 
*/

WITH CUSTOMER_RANK AS(
	SELECT 
		MONTH(O.DATE) AS MONTH,
		YEAR(O.DATE) AS YEAR,
        C.ID,
		C.FIRSTNAME,
		C.LASTNAME,
        COUNT(O.ID) AS ORDERS,
        COUNT(DISTINCT I.ID) AS ITEMS,
		SUM(O.TOTALAMMOUNT) AS TOTAL,
		RANK() OVER (  
			PARTITION BY MONTH(O.DATE)
			ORDER BY SUM(O.TOTALAMMOUNT) DESC
		) POSICAO # RANK OVER THE TOTAL AMOUNT OF ALL ORDERS OF THE SELLER AND RESET THE RANK WHEN THE MONTH CHANGES
	FROM 
		MELI.CUSTOMER C
		INNER JOIN MELI.ORDER O ON C.ID = O.SELLER 
		INNER JOIN MELI.ITEM I  ON O.ITEM = I.ID
		INNER JOIN MELI.CATEGORY CAT ON I.CATEGORY = CAT.ID
	WHERE 
		YEAR(O.DATE) = 2020
		AND CAT.NAME = 'CELULARES'
	GROUP BY 
		MONTH(O.DATE) ,
		YEAR(O.DATE) ,
		C.ID,
		C.FIRSTNAME,
		C.LASTNAME
)
SELECT * FROM CUSTOMER_RANK WHERE POSICAO <= 5;

/* RESPOSTA NEGÓCIO 3
É solicitada uma nova tabela a ser preenchida com o preço e status dos Itens no final do dia. Lembre-se de que deve ser reprocessável. 
Vale ressaltar que na tabela Item teremos apenas o último status informado pelo PK definido. (Pode ser resolvido através de StoredProcedure)
*/

delimiter //
CREATE PROCEDURE LOAD_EOD_ITEMS(IN PROCESS_DATE  DATE)
BEGIN
	DELETE FROM EOD_ITEMS WHERE DATE = PROCESS_DATE;
	INSERT INTO EOD_ITEMS 
	SELECT 
		PROCESS_DATE AS DATE,
		ID,
		NAME,
		PRICE,
		CASE WHEN PROCESS_DATE BETWEEN CREATED_AT AND coalesce(CANCELLED_AT, CURDATE()) THEN 'ATIVO' ELSE 'CANCELADO' END AS STATUS
	FROM 
		ITEM;
END //
CALL LOAD_EOD_ITEMS('2024-04-09');
