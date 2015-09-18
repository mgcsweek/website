import remove, insert from table

class ModelMock 
    new: (keys) =>
        @allowed_keys = keys
        @keys_lookup = { }
        @keys_lookup[k] = true for k in *keys

    find: (criteria) =>
        key = nil
        if type criteria == 'table'
            for c in *@allowed_keys
                if criteria[c]
                    key = c

            return nil, "keyed search by #{criteria} not supported" if not key
        else
            key = 'id'
            criteria = { id: criteria }

        for a in *@data
            return a if a[key] == criteria[key]

        nil, 'no such item'

    create: (item) =>
        if type item != 'table'
            return nil, 'invalid arguments'

        for a in *@data
            return nil, 'duplicate id' if a.id == item.id

        for k, _ in pairs item
            return nil, 'invalid key' if not @keys_lookup[k]

        item.parent = self
        item.delete = =>
            @parent\delete self

        item.update = (new) =>
            @parent\update self, new

        insert @data, item

    delete: (item) =>
        for i = 1, #@data
            a = @data[i]
            if a.id == item.id
                remove @data, i

    update: (item, new) =>
        return nil, "can't change id" if item.id != new.id

        for i = 1, #@data
            return @data[i] = new if @data[i].id == new.id

        nil, 'no such item'

