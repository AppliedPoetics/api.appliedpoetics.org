class Constraint
    def self.create(cat, mtd, params)
        # { category: cat, method: mtd, status: "created" }
        cls = Object.const_get(cat.capitalize)
        cls.create(mtd, params)
    end
end