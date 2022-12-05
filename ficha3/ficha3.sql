-- 1
--  Instrução SELECT que devolva todos os registos da tabela nation, 
-- ordenado pela coluna n_name de forma descendente e ascente pela 
-- n_regionkey.

select * from nation order by n_name desc, n_regionkey asc

-- 2
-- Instrução SELECT que devolva os valores da coluna s_name da tabela 
-- supplier que tem a chave primaria compreendia entre 2 e 5. 

select s_name from supplier where s_suppkey between 2 and 5

-- 3
-- Instrução SELECT que devolva os valores das colunas o_orderkey,
-- o_orderstatus da tabela order com o valor 3 ou valor 5, no campo 
-- o_orderkey.

select o_orderkey, o_orderstatus from orders where o_orderkey in (3, 5)

-- 4
-- Instrução SELECT que devolve os valores das colunas o_orderkey, 
-- o_totalprice e um campo calculado com a designação "New Price" do 
-- registo com o valor 5 no campo o_orderkey. O campo “New Price” é o 
-- resultado do produto do valor contido em o_totalprice com o valor 
-- 1.20. Os valores numéricos devem ser arredondados à segunda casa 
-- decimal.

select o_orderkey, o_totalprice, round(o_totalprice * 1.2, 2) as "New Price" from orders where o_orderkey = 5

-- 5
-- Instrução SELECT que concatena os valores dos campos c_phone e 
-- c_name, da tabela customer, e atribui a designação Nome à coluna a 
-- apresentar no resultado. A consulta deve ainda devolver outra coluna 
-- com o endereço dos clientes (c_address) concatenado com os 
-- comentários (c_comment). A coluna que vai conter o endereço deve 
-- ter a designação "Endereço ". Deve devolver apenas 10 registos 
-- ordenados por ordem crescente da coluna c_name.

select concat(c_phone, ' ', c_name) as "Nome", concat(c_address, ' ', c_comment) as "Endereço" from customer order by c_name asc limit 10

-- 6
-- Instrução SELECT que devolva, o nome e telefone dos fornecedores 
-- (tabela customers) cujo nome termina em “42”

select c_name, c_phone from customer where c_name like '%42'

-- 7
-- Construa uma consulta que devolva o número da fatura, a data da 
-- fatura e o total da fatura das faturas cuja data de vencimento se refere 
-- aos últimos 30 dias

select o_orderkey, o_orderdate, o_totalprice from orders where o_orderdate > CURRENT_TIMESTAMP - interval '30 days'

-- 8
-- Instrução SELECT que devolva o número da ordem(o_orderkey) e o 
-- valor total(o_totalprice). Devem ser consideradas apenas as faturas 
-- com data entre 1 de janeiro e 30 de Agosto de 1998, cujo total é 
-- superior a 2000,50€ . Os registos devolvidos deverão estar ordenados 
-- por ordem decrescente do número de fatura

select o_orderkey, o_totalprice from orders where o_orderdate > '1998-01-01' and o_orderdate < '1998-08-30' and o_totalprice > 2000.50 order by o_orderkey DESC

-- 9
-- Construa uma consulta que devolva todos os dados das ordens cuja data 
-- de pagamento não está definida. Para tal, pode utilizar a cláusula IS 
-- NULL. Esta cláusula permite verificar se uma determinada coluna 
-- possui valores nulos. E se pretender que sejam devolvidos todos os 
-- dados das faturas cuja data de pagamento não está definida?

select * from orders where o_orderdate IS NULL
select * from orders where o_orderdate IS NOT NULL

-- 10
-- Construa uma consulta que devolva o número da ordem (o_orderkey)
-- com o cabeçalho Numero Ordem, o preço total da ordem(o_totalprice)
-- com o cabeçalho Preço Total, o estado da encomenda (o_orderstatus) 
-- com o cabeçalho estado da encomenda e os valores concatenados dos 
-- campos o_orderpriority e o_clerk, com o cabeçalho observações. 
-- Devem ser consideradas apenas as faturas com data inferior a 05-01-
-- 1998, cujo total é superior a 500 e cujo o campo o_comment não é 
-- nulo.

select 
o_orderkey as "Numero Ordem", 
o_totalprice as "Preco Total", 
o_orderstatus as "Estado da Encomenda", 
concat(o_orderPriority, ' ', o_clerk) as "Observacoes" 
from orders where o_orderdate < '1998-01-05' and o_totalprice > 500 and o_comment is not null

-- 11
-- Construa uma query que apresente o somatório de todas as vendas
-- (campo o_orderdate) realizadas apenas no ano 1998. O campo deve 
-- ter um cabeçalho com o título “Valor total”

select sum(o_totalprice) as "Valor Total"
from orders where o_orderdate >= '1998-01-01' and o_orderdate <= '1998-12-31'

-- 12 
-- Elabore uma query que conte o número de clientes na base de dados, 
-- que tem a c_nationkey igual a 1

select count(c_custkey) from customer where c_nationkey = 1