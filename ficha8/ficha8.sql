-- 1
-- Elabore um trigger que mantenha o preço total de uma encomenda atualizado.
-- Crie uma encomenda com 5 itens. Teste o trigger, após a inserção, atualização
-- das quantidades e eliminação. (Tabelas utilizadas lineitem e orders)

CREATE FUNCTION trigger_ex1() 
RETURNS trigger 
AS $$
BEGIN
    -- Check that empname and salary are given
    IF NEW.empname IS NULL THEN
        RAISE EXCEPTION 'empname cannot be null';
    END IF;
    IF NEW.salary IS NULL THEN
        RAISE EXCEPTION '% cannot have null salary', NEW.empname;
    END IF;

    -- Who works for us when they must pay for it?
    IF NEW.salary < 0 THEN
        RAISE EXCEPTION '% cannot have a negative salary', NEW.empname;
    END IF;

    -- Remember who changed the payroll when
    NEW.last_date := current_timestamp;
    NEW.last_user := current_user;
    RETURN NEW;
END; $$ 
LANGUAGE plpgsql;

CREATE TRIGGER emp_stamp 
BEFORE INSERT OR UPDATE ON emp
FOR EACH ROW EXECUTE FUNCTION trigger_ex1();