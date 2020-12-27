import React from 'react';
import ReactDOM from 'react-dom';

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

        this.diffRef = React.createRef();
    }

    //guess the idea is passing up a ref through callback
    //and then setting it on the diff?
    //so diff.bboxRef and diff.diffRef?
    componentDidMount() {
        const diff = this.state.diff;
        diff['diffRef']=this.diffRef;
        this.setState({
            diff
        });
    }

    componentWillUnmount() {
        this.diffRef = null;
    }

    render() {

        //style settings
        const lineWidth = 3;
        const hoverLineWidth = 3;

        const defaultStyle = {
            //outline: `${lineWidth}px solid ${this.state.color}`,
            visbility: "visible" //TODO: toggle individual box visibility
            //visibility: this.props.bbox.isVisible ? "visible" : "hidden"
        };

        const hoverStyle = {
            outline: `${lineWidth + hoverLineWidth}px solid ${this.state.hoverColor}`
        };

        const rectStyle = !(this.props.diffBboxHoverId == this.props.diff.id) ?
              defaultStyle : hoverStyle;

        return(
            <div
              ref={this.diffRef} style={rectStyle}
              onClick={() => this.props.diffClickHandler(this.diffRef, this.props.diff)}
              onMouseEnter={ () => this.props.diffBboxHoverHandler(this.props.diff.id)}
              onMouseLeave={ () => this.props.diffBboxHoverHandler(0)} >

                <p> Diff: {this.props.diff.id} </p>
                <p> Selector: { this.props.diff.selector } </p>
                <p> type: { this.props.diff.diffType } </p>
                <p> summary_delta: { this.props.diff.summary_delta } </p>
                <p> summary_added: { this.props.diff.summary_added } </p>
                <p> summary_removed: { this.props.diff.summary_removed } </p>
                <hr/>
            </div>
        );
    }
}
