var data,vizData,vocCatScale;vocCatScale=d3.scale.ordinal().range(["#FB514E","#2d82ca","#49af37","#9065c8"]),data=null,$(window).load(function(){return vizData()}),$(window).resize(function(){return console.log("resizing, redrawing"),vizData()}),vizData=function(){var t,a,o,e,i,n,l;return i="#content",t=$(i),console.log("Our data!",data),l=t.width(),a=t.height()/2,l>767?(console.log("==> Desktop"),e=!1,o={left:16,right:16,top:16,bottom:16}):(console.log("==> Mobile"),e=!0,o={left:16,right:16,top:16,bottom:16}),n=d3.select("#viz-svg"),n.attr({width:l,height:a}),n.append("rect").attr({width:l-10,height:a-10,fill:"red",x:10,y:10})};