CREATE TRIGGER trg_expense_approver BEFORE INSERT OR UPDATE OF approved_by ON public.expense FOR EACH ROW EXECUTE FUNCTION fn_check_expense_approver();

CREATE TRIGGER trg_expense_audit AFTER INSERT OR DELETE OR UPDATE ON public.expense FOR EACH ROW EXECUTE FUNCTION fn_expense_audit();
