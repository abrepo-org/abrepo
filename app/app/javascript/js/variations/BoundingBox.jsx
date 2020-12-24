import React from 'react';
import ReactDOM from 'react-dom';

export default class BoundingBox extends React.Component {

    constructor(props) {
        super(props);
        //console.log("BoundingBox", this.props.diff);
    }

    rectClickHandler() {
        console.log("RECT CLICK", this.props.diff.id)
    }

    render() {
        //settings
        const lineWidth = 3;
        const defaultStyle = {
            outline: `${lineWidth}px solid red`,
            visbility: "visible" //TODO: toggle individual box visibility
            //visibility: this.props.bbox.isVisible ? "visible" : "hidden"
        };

        const hoverStyle = {
            outline: `${lineWidth}px solid blue`
        };

        const rectStyle = defaultStyle; //TODO: hover or default

        const id = this.props.diff.id;
        const dim = this.props.isControl? this.props.diff.origDim : this.props.diff.newDim;
        const boundingBox = dim.boundingBox;

        if (!boundingBox || !dim.isVisible) return null;

        const selector = boundingBox.selector;
        const coord = boundingBox.rect;

        return(

            <rect id={`svgRect${id}`} style={rectStyle}
                  //ref={(ref) => { this.rectRefs[i] = ref; } }
              x={coord.x - lineWidth} y={coord.y - lineWidth}
              width={coord.width + lineWidth} height={coord.height + lineWidth}
              stroke="red" fill="red" fillOpacity="0.2"
              cursor="pointer"
              onClick={() => { this.rectClickHandler() }}
              // onMouseEnter={this.mouseEnterHandler.bind(that, i) }

              >

              <title>{selector}</title>

            </rect>

        );
    }
}
