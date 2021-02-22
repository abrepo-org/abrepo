import React from 'react';
import ReactDOM from 'react-dom';

export default class BoundingBox extends React.Component {

    constructor(props) {
        super(props);

        //elemType colors: require contrast, so darker tends to be better visually
        const colors = {
            //diffType: {}
            //actionType: {}
            'ADDED': 'green',
            'CHANGED': 'blueviolet',
            'REMOVED': 'red'
        };

        const hoverColor = 'blue';

        this.state = {
            elem: this.props.elem,
            hoverColor,
            color: colors[this.props.elem.type]
        };

        this.bboxRef = React.createRef();
    }

    // rectClickHandler() {
    //     console.log("RECT CLICK", this.bboxRef.current, this.props.elem.id)
    // }

    componentDidMount() {

        const elem = this.state.elem;

        if(this.props.isControl) {
            elem.origDim['bboxRef'] = this.bboxRef;
        } else {
            elem.newDim['bboxRef'] = this.bboxRef;
        }

        //elem.dim['bboxRef'] = this.bboxRef;
        //elem.dim['ref'] = this.ref;

        this.setState({
            elem
        });
    }

    componentWillUnmount() {
        this.bboxRef = null;
    }

    render() {
        //style settings
        const lineWidth = 3;
        const hoverLineWidth = 3;

        const defaultStyle = {
            outline: `${lineWidth}px solid ${this.state.color}`,
            visbility: "visible" //TODO: toggle individual box visibility
            //visibility: this.props.bbox.isVisible ? "visible" : "hidden"
        };

        const hoverStyle = {
            outline: `${lineWidth + hoverLineWidth}px solid ${this.state.hoverColor}`
        };

        const rectStyle = !(this.props.bboxHoverId == this.props.elem.id) ?
              defaultStyle : hoverStyle;

        //console.log("RECT", this.props.bboxHoverId, rectStyle)
        //data
        const id = (this.props.isControl ? "c" : "") + this.props.elem.id;
        const dim = this.props.elem.dim;
        const boundingBox = dim.boundingBox;

        if (!boundingBox || !dim.isVisible) return null;

        const selector = boundingBox.selectorDisplayName || boundingBox.selector;
        const coord = boundingBox.rect;

        return(

            <rect id={`svgRect${id}`} style={rectStyle}
                  x={coord.x - lineWidth} y={coord.y - lineWidth}
                  width={coord.width + lineWidth} height={coord.height + lineWidth}
                  stroke={this.state.color} fill={this.state.color} fillOpacity="0.2"

                  onClick={() => this.props.bboxClickHandler(this.bboxRef, this.props.elem) }
                  onMouseEnter={ () => this.props.bboxHoverHandler(this.props.elem.id)}
                  onMouseLeave={ () => this.props.bboxHoverHandler(0)}
                  ref={this.bboxRef}
              >

              <title>{selector}</title>

            </rect>

        );
    }
}
