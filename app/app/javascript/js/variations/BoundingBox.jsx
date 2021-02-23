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
            'REMOVED': 'red',

            'CLICK' : 'orange'
        };

        const hoverColor = 'blue';

        this.state = {
            elem: this.props.elem,
            hoverColor,
            color: colors[this.props.elem.type]
        };

        this.ref = React.createRef();
    }

    // rectClickHandler() {
    //     console.log("RECT CLICK", this.ref.current, this.props.elem.id)
    // }

    componentDidMount() {
        //should call higher level handler setBboxRefs: {elem_id: bbox}
        let dim = this.props.dim;
        dim['ref'] = this.ref;
        this.setState({ dim });
    }

    componentWillUnmount() {
        this.ref = null;
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
        const rect = this.props.elem.ref &&
                     this.props.elem.ref.current.getClientRects()[0];

        return(

            <rect id={`svgRect${id}`} style={rectStyle}
                  x={coord.x - lineWidth} y={coord.y - lineWidth}
                  width={coord.width + lineWidth} height={coord.height + lineWidth}
                  stroke={this.state.color} fill={this.state.color} fillOpacity="0.2"

                  onClick={() => this.props.bboxClickHandler(this.props.elem, rect) }
                  onMouseEnter={ () => this.props.bboxHoverHandler(this.props.elem.id)}
                  onMouseLeave={ () => this.props.bboxHoverHandler(0)}
                  ref={this.ref}
              >

              <title>{selector}</title>

            </rect>

        );
    }
}
