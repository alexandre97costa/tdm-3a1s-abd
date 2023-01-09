--1)
--a) Criação das tabelas: Produtos, Tipos e Clientes

create table produto ( codigo integer not null default nextval(produto_id_seq) primary key, codt integer not null, nome varchar2(100), qt_stock float, st_seguranca float, preco float,
                      foreign key (codt) references tipo (codt));


create table tipo ( codt integer not null default nextval(tipo_id_seq) primary key, designacao varchar2(100));


create table cliente ( codc integer not null default nextval(cliente_id_seq) primary key, nome varchar2(100), rua varchar2(100), numeroporta varchar2(10), teleffxo varchar2(9), telemovel varchar2(9));

--b) Criação das sequências necessárias

create sequence produto_id_seq;


create sequence tipo_id_seq;


create sequence cliente_id_seq;

--c) Listar o nome dos produtos e do seu tipo por ordem decrescente da existente em stock

select produto.nome,
       tipo.designacao
from produto
left join tipo on produto.codt = tipo.codt
order by produto.qt_stock desc;

--d) Listar os dados de todos os clientes cujo nome inicia em Na;

Select nome
from cliente
where nome like 'Na%';

--e) Atualizar o telemóvel para 111111111 do cliente cujo código é 123

update table
set teleffixo = 111111111
where codc = 123;

--f) Remover todos os clientes que não tenham facturas emitidas

delete
from cliente
where codc not in
        ( select codc
         from facturas_cliente ) --g) Inserir o tipo de produto xpto

    insert into tipo(codt, designacao)
values( nextval(tipo_id_seq, 'xpto') ) --h) Listar os nomes dos produtos com maior quantidade em stock

select nome
from produto
order by qt_stock --2)
--a) Registo de um novo cliente

create or replace procedure insert_cliente( nome varchar, rua varchar, numeroporta varchar, teleffixo varchar, telefmovel varchar) language plpgsql as $$
begin
    insert into cliente(codc, nome, rua, numeroporta, teleffixo, telefmovel) values (
        nextval(cliente_id_seq),
        nome,
        rua,
        numeroporta,
        teleffixo,
        telefmovel
    )
end; $$ 

--b) Determinação, através da utilização de um cursor, do valor total de compras de um determinado cliente

create or replace procedure total_compras( cliente_id cliente.id%type) language plpgsql as $$
declare
    total produto.preco%type
    total_c cursor for
        select sum(produto.preco * linha_fatura.quantidade) from cliente
        inner join facturas_cliente on cliente.codc = facturas_cliente.codc
        inner join linha_fatura on facturas_cliente.numero = linha_fatura.numero
        inner join produto on produto.codigo = linha_fatura.codigo
        where cliente.codc = cliente_id
begin
    open total_c;

    fetch total_c into total;
    raise notice 'Total de compras do cliente #% é %', cliente_id, total;

    close total_c;
end; $$

-- 3)
-- a) indique como invocaria o procedimento acima mencionado

call proc1(number, varchar)
