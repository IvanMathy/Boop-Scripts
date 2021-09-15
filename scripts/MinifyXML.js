/**
	{
		"api":1,
		"name":"Minify XML",
		"description":"Cleans and minifies XML/HTML documents.",
		"author":"Ivan",
		"icon":"broom",
		"tags":"html,minify,clean,indent",
        "bias": -0.1
	}
**/

const { xmlmin } = require('@boop/vkBeautify')


function main(state) {
	state.text = xmlmin(state.text)	
}
