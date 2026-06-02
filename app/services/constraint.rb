class Constraint
    def self.create(cat, mtd, params)
        class_name = cat.split("_").map(&:capitalize).join
        cls = Object.const_get(class_name)
        cls.create(mtd, params)
    end
end
