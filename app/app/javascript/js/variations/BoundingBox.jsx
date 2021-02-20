import React from 'react';
import ReactDOM from 'react-dom';

export default class BoundingBox extends React.Component {

    constructor(props) {
        super(props);

        //DiffType colors: require contrast, so darker tends to be better visually
        const colors = {
            'ADDED': 'green',
            'CHANGED': 'blueviolet',
            'REMOVED': 'red'
        };

        const hoverColor = 'blue';

        this.state = {
            diff: this.props.diff,
            hoverColor,
            color: colors[this.props.diff.diffType]
        };

        this.bboxRef = React.createRef();
    }

    // rectClickHandler() {
    //     console.log("RECT CLICK", this.bboxRef.current, this.props.diff.id)
    // }

    componentDidMount() {

        const diff = this.state.diff;

        if(this.props.isControl) {
            diff.origDim['bboxRef'] = this.bboxRef;
        } else {
            diff.newDim['bboxRef'] = this.bboxRef;
        }

        this.setState({
            diff
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

        const rectStyle = !(this.props.diffBboxHoverId== this.props.diff.id) ?
              defaultStyle : hoverStyle;

        //console.log("RECT", this.props.diffBboxHoverId, rectStyle)
        //data
        const id = (this.props.isControl ? "c" : "") + this.props.diff.id;
        const dim = this.props.isControl? this.props.diff.origDim : this.props.diff.newDim;
        const boundingBox = dim.boundingBox;

        if (!boundingBox || !dim.isVisible) return null;

        const selector = boundingBox.selectorDisplayName || boundingBox.selector;
        const coord = boundingBox.rect;

        return(

            <rect id={`svgRect${id}`} style={rectStyle}
                  x={coord.x - lineWidth} y={coord.y - lineWidth}
                  width={coord.width + lineWidth} height={coord.height + lineWidth}
                  stroke={this.state.color} fill={this.state.color} fillOpacity="0.2"
                  onClick={() => this.props.bboxClickHandler(this.bboxRef, this.props.diff) }
                  onMouseEnter={ () => this.props.diffBboxHoverHandler(this.props.diff.id)}
                  onMouseLeave={ () => this.props.diffBboxHoverHandler(0)}
                  ref={this.bboxRef}
                  //cursor="pointer"
                  // onMouseEnter={this.mouseEnterHandler.bind(that, i) }
              >

              <title>{selector}</title>

            </rect>

        );
    }
}
