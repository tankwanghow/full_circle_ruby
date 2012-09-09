module AuditsHelper
  def render_audits(audited_model)
    return '' unless audited_model.respond_to?(:audits)
    audits = (audited_model.audits || []).dup.sort{|a,b| b.created_at <=> a.created_at}
    res = ''
    audits.each_with_index do |audit, index|
      older_audit = audits[index + 1]
      res += content_tag(:div, class: 'audit') do
        content_tag(:span, audit.action, class: "action #{audit.action}") +
        content_tag(:span, audit.user ? "by #{audit.user.name}" : 'by System', class: "user") +
        content_tag(:span, audit.created_at.strftime("%Y-%m-%d %H:%m:%S"), class: "timestamp") +
        content_tag(:div, class: 'changes') do
          changes = if older_audit.present?
            audit.delta(older_audit).collect do |k, v|
              "<span class='bold'>" + audited_model.class.human_attribute_name(k) +
              "</span>:" +
              content_tag(:span, v.last, class: 'current') +
              content_tag(:span, v.first, class: 'previous') + "<br/>"
            end
          else
            audit.change_log.reject{|k, v| v.blank?}.collect {|k, v| "<span class='bold'>#{audited_model.class.human_attribute_name(k)}</span>: #{v}<br/>"}
          end
          changes.join.html_safe
        end
      end
    end
    res.html_safe
  end

  def record_created_info(log=nil)
    if log
      content_tag :div, "by #{log.user.name}", class: "medium"
      content_tag :div, time_ago_in_words(log.created_at, true) + " ago", class: "created_at"
    end
  end
end

