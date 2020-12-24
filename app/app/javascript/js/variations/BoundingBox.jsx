import React from 'react';
import ReactDOM from 'react-dom';

export default class BoundingBox extends React.Component {

    constructor(props) {
        super(props);

        //DiffType colors
        const colors = {
            'ADDED': 'green',
            'CHANGED': 'pink',
            'REMOVED': 'red'
        };

        const hoverColor = 'blue';

        this.state = {
            hoverColor,
            color: colors[this.props.diff.diffType]
        }
    }

    rectClickHandler() {
        console.log("RECT CLICK", this.props.diff.id)
    }

    render() {
        //style settings
        const lineWidth = 3;
        const defaultStyle = {
            outline: `${lineWidth}px solid ${this.state.color}`,
            visbility: "visible" //TODO: toggle individual box visibility
            //visibility: this.props.bbox.isVisible ? "visible" : "hidden"
        };

        const hoverStyle = {
            outline: `${lineWidth}px solid ${this.state.hoverColor}`
        };

        const rectStyle = !(this.props.diffHoverId== this.props.diff.id) ?
                          defaultStyle : hoverStyle;

        console.log("RECT", this.props.diffHoverId, rectStyle)
        //data
        const id = this.props.diff.id;
        const dim = this.props.isControl? this.props.diff.origDim : this.props.diff.newDim;
        const boundingBox = dim.boundingBox;

        if (!boundingBox || !dim.isVisible) return null;

        const selector = boundingBox.selector;
        const coord = boundingBox.rect;

        return(

            <rect id={`svgRect${id}`} style={rectStyle}
                  x={coord.x - lineWidth} y={coord.y - lineWidth}
                  width={coord.width + lineWidth} height={coord.height + lineWidth}
                  stroke={this.state.color} fill={this.state.color} fillOpacity="0.2"
                  onClick={() => { this.rectClickHandler() }}
                  //cursor="pointer"
                  // onMouseEnter={this.mouseEnterHandler.bind(that, i) }
              >

              <title>{selector}</title>

            </rect>

        );
    }
}
