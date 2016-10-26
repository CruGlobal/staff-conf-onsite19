ActiveAdmin.register PaperTrail::Version do
  index do
    selectable_column

    column('Record', sortable: [:item_type, :id]) { |v| version_label(v) }
    column :event
    column('When', sortable: :created_at) { |v| v.created_at.to_s :long }
    column('Editor', sortable: :whodunnit) { |v| editor_link(v) }

    actions
  end

  show do
    columns do
      column do
        attributes_table do
          row :id
          row('Record') { |v| version_label(v) }
          row :event
          row('When')   { |v| v.created_at.to_s :long }
          row('Editor') { |v| editor_link(v) }
        end
      end

      column do
        panel 'Previous Version Details' do
          obj = previous_version_hash(paper_trail_version)

          if obj.any?
            table do
              thead do
                tr do
                  th 'Attribute'
                  th 'Value'
                end
              end

              tbody do
                obj.each do |key, value|
                  tr do
                    td strong key.humanize
                    td do
                      case key
                      when 'description'
                        html_full(value)
                      else
                        value
                      end
                    end
                  end
                end
              end
            end
          else
            strong 'This is the first version of the record.'
          end
        end
      end
    end

    active_admin_comments
  end
end
