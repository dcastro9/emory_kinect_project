package ui.elements
{
	import flash.geom.Rectangle;
	
	import flare.scale.ScaleType;
	import flare.vis.Visualization;
	import flare.vis.data.Data;
	import flare.vis.operator.encoder.ColorEncoder;
	import flare.vis.operator.encoder.ShapeEncoder;
	import flare.vis.operator.encoder.SizeEncoder;
	import flare.vis.operator.layout.AxisLayout;

	public class VisualizationPage extends Page
	{
		private var vis:Visualization;
		
		public function VisualizationPage() {
			super();
			this.addHeader("User Data Visualization");
			vis = new Visualization();
			vis.x = this.PAGE_MARGIN;
			vis.y = this.PAGE_MARGIN + 6;
			vis.bounds = new Rectangle(0,0, 500, 500);
//			vis.scaleX = 0.8;
//			vis.scaleY = 0.8;
			addChild(vis);
		}
		
		public function addData(data:Data):void {
			vis.data = data;
			// define the visual encodings
			vis.data.nodes.setProperties({
				fillColor: 0x000000, // transparent fill to catch mouse hits
				lineWidth: 1
			});
			vis.operators.add(new AxisLayout("data.value1", "data.value2"));
			vis.operators.add(new SizeEncoder("data.value1"));
			vis.operators.add(new ShapeEncoder("data.value1"));
			vis.operators.add(new ColorEncoder("data.value1", Data.NODES,
				"lineColor", ScaleType.CATEGORIES));
			vis.xyAxes.xAxis.fixLabelOverlap = false; // let labels overlap
			vis.update();
		}
	}
}