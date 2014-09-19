`import LucyAdapter from './lucy'`

Adapter = LucyAdapter.extend

	defaultSerializer: "lucy"
	host: "http://localhost:5984"
	namespace: "jsfoo"

`export default Adapter`