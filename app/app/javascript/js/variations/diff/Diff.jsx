import React from 'react';
import ReactDOM from 'react-dom';
import DiffView from './DiffView.jsx';

export default class Diff extends React.Component {

    constructor(props) {
        super(props);

        const hoverColor = 'blue';
        const color = '#faa';

        this.state = {
            diff: this.props.diff,
            hoverColor,
            color
        };

        this.ref = React.createRef();
    }

    //guess the idea is passing up a ref through callback
    //and then setting it on the diff?
    componentDidMount() {
        const diff = this.state.diff;
        diff['ref']=this.ref;

        this.setState({
            diff
        });
    }

    componentWillUnmount() {
        this.ref = null;
    }

    render() {

        //style settings
        const lineWidth = 1;
        const hoverLineWidth = 1;

        const defaultStyle = {
            //outline: `${lineWidth}px solid ${this.state.color}`,
            visbility: "visible" //TODO: toggle individual box visibility
            //visibility: this.props.bbox.isVisible ? "visible" : "hidden"
        };

        const hoverStyle = {
            background: 'whitesmoke',
            outline: `${lineWidth + hoverLineWidth}px solid ${this.state.hoverColor}`
        };

        const rectStyle = !(this.props.bboxHoverId == this.props.diff.id) ?
              defaultStyle : hoverStyle;

        return(
            <div
              className='diff p-3'
              ref={this.ref} style={rectStyle}
              onClick={() => this.props.diffClickHandler(this.ref, this.props.diff)}
              onMouseEnter={ () => this.props.bboxHoverHandler(this.props.diff.id)}
              onMouseLeave={ () => this.props.bboxHoverHandler(0)}>

                <DiffView diff={this.props.diff} detail={true} {...this.props} />

            </div>
        );
    }
}
