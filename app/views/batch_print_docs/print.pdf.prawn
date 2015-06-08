load Document.printable_doc_paths[Document.find(@docs[0]).searchable_type.underscore.to_sym]

doc_type_pdf_class = (Document.find(@docs[0]).searchable_type + 'Pdf').classify.constantize

i = doc_type_pdf_class.new(@docs.map { |t| Document.find(t).searchable }, self, @static_content)