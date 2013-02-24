if @transactions.count > 0
  response.headers["Content-Disposition"] = "attachment; filename='#{@account.name1.underscore}_transactions.csv'"

  CSV.generate do |csv|
    csv << ["Date", "Doc Type", "Doc No", "Terms", "Partuculars", "Debit", "Credit"]
    @transactions.each do |t|
      csv << [
        t.transaction_date,
        t.doc_type,
        docnolize(t.doc_id, ' #'),
        term_string(t.terms),
        t.note,
        t.amount > 0 ? t.amount : 0,
        t.amount < 0 ? t.amount.abs : 0
      ]
    end
  end
end
