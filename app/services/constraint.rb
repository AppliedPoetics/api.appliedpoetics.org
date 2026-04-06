class Constraint
    def self.create(cat, mtd, params)
        cls = Object.const_get(cat.capitalize)
        cls.create(mtd, params)
    end
end