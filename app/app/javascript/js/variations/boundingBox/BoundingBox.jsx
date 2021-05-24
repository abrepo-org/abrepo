import React from 'react';
import ReactDOM from 'react-dom';

export default class BoundingBox extends React.Component {

    constructor(props) {
        super(props);

        this.ref = React.createRef();
    }

    componentDidMount() {
        //TODO: refactot to higher level handler setBboxRefs: {elem_id: bbox}
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
            outline: `${lineWidth}px solid ${this.props.color}`,

            //TODO:not sure if visibility for diffPanel is confusing
            //visually we do see a diff...
            visibility: (this.props.dim.isVisible && this.props.elem.diffPanel != "min") ?
                "visible" : "hidden"
        };

        const hoverStyle = {
            outline: `${lineWidth + hoverLineWidth}px solid ${this.props.hoverColor}`
        };

        const rectStyle = !(this.props.bboxHoverId ==
                            (this.props.elem.group_id || this.props.elem.id)) ?
              defaultStyle : hoverStyle;

        //data
        const id = (this.props.isControl ? "c" : "") + this.props.elem.id;
        const dim = this.props.dim;
        const boundingBox = dim.boundingBox;

        if (!boundingBox) return null;

        const selector = boundingBox.selectorDisplayName || boundingBox.selector;
        const coord = boundingBox.rect;

        return(

            <rect id={`svgRect${id}`} style={rectStyle}
                  x={coord.x - lineWidth} y={coord.y - lineWidth}
                  width={coord.width + lineWidth} height={coord.height + lineWidth}
                  stroke={this.props.color} fill={this.props.color} fillOpacity="0.2"

                  onClick={() => this.props.bboxClickHandler(this.props.elem) }
                  onMouseEnter={ () => this.props.bboxHoverHandler(this.props.elem.group_id || this.props.elem.id)}
                  onMouseLeave={ () => this.props.bboxHoverHandler(0)}
                  ref={this.ref}
            >

              <title>{selector}</title>

            </rect>

        );
    }
}
