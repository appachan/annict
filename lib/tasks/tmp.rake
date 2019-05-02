# frozen_string_literal: true

namespace :tmp do
  task fix_asin_on_work_image: :environment do
    WorkImage.where.not(asin: "").find_each do |wi|
      next if wi.asin.match?(/\A[0-9A-Z]{10}\z/)
      print "--- work_image: #{wi.id} "
      asin = wi.asin.scan(%r{(product|dp)/([0-9A-Z]{10})}).flatten[1]
      if asin&.match?(/\A[0-9A-Z]{10}\z/)
        puts "- #{asin}"
        wi.update_column(:asin, asin)
      else
        puts "- asin not found: #{wi.asin}"
      end
    end
  end

  task :paperclip_to_shrine, %i(from) => :environment do |_, args|
    from = Time.zone.parse(args[:from]).beginning_of_day
    errors = []

    [
      { model: WorkImage, paperclip_field: :attachment, shrine_field: :image },
      { model: UserlandProject, paperclip_field: :icon, shrine_field: :image },
      { model: Pv, paperclip_field: :thumbnail, shrine_field: :image },
      { model: Profile, paperclip_field: :tombo_avatar, shrine_field: :image },
      { model: Profile, paperclip_field: :tombo_background_image, shrine_field: :background_image },
      { model: Item, paperclip_field: :thumbnail, shrine_field: :image }
    ].each do |data|
      resources = data[:model].where("updated_at >= ?", from)
      resources.find_each do |r|
        next if r.send(data[:paperclip_field]).blank?
        puts "--- #{data[:model].name}: #{r.id}"

        image_url = "#{ENV.fetch('ANNICT_FILE_STORAGE_URL')}/#{r.send(data[:paperclip_field]).path(:original)}"

        unless r.update(data[:shrine_field] => Down.open(image_url))
          error = { model: data[:model].name, id: r.id, messages: r.errors.messages }
          puts "--- Error!: #{error}"
          errors << error
        end
      end
    end

    puts errors
  end
end
