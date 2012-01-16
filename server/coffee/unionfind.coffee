Array::unique = -> @filter (s, i, a) -> i == a.lastIndexOf s

module.exports = UnionFind =
	makeSet: (x) ->
		x.parent = x

	union: (x, y) ->
		xRoot = UnionFind.find x
		yRoot = UnionFind.find y
		xRoot.parent = yRoot

	find: (x) ->
		if x.parent != x
			x.parent = UnionFind.find x.parent
		x.parent

	components: (elements) ->
		for root in (UnionFind.find x for x in elements).unique()
			elements.filter (x) -> root == UnionFind.find x
