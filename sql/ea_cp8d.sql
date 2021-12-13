select emp.name as emp, tax_no, replace(emp.id_no, '-', '') as ic,
       case when emp.marital_status = 'Married' and emp.partner_working = true 
         then 3 
       else 
         case when emp.marital_status = 'Married' and emp.partner_working = false 
           then 2 
         else 
           1 
         end 
       end as haha,  
       2 as bosspaytax, emp.children, emp.children * 1000 as child_deduction,
       sum(case when st.classifiaction = 'Addition' then sn.quantity * sn.unit_price else 0 end) as income,
	   '' as goods, '' as lodging, '' as shareoption, '' as nontaxable, '' as tp1, '' as tp1zakat, 
       '' as dir_fee,
       '' as bonus,
       sum(case when st.name in ('EPF By Employee') then sn.quantity * sn.unit_price else 0 end) as kwsp,
       '' as zakatfromsalary,
       sum(case when st.name in ('Employee PCB') then sn.quantity * sn.unit_price else 0 end) as pcb,
       '' as cp38
  from employees emp 
 inner join pay_slips ps on emp.id = ps.employee_id
 inner join salary_notes sn on ps.id = sn.pay_slip_id
 inner join salary_types st on st.id = sn.salary_type_id
 where ps.pay_date <= '2020-12-31'
   and ps.pay_date >= '2020-01-01'
   and nationality ilike '%malay%'
   and emp.epf_no not in ('-', '')
 group by emp.name, tax_no, emp.id_no, marital_status, emp.partner_working, emp.children
 order by 1
