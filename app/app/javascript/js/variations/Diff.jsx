import React from 'react';
import ReactDOM from 'react-dom';

export default class Diff extends React.Component {

    constructor(props) {
        super(props);

        this.state = {
            diff: this.props.diff
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
        return(
            <div
              ref={this.diffRef}
              onClick={() => this.props.diffClickHandler(this.diffRef, this.props.diff)}
              onMouseEnter={ () => this.props.diffHoverHandler(this.props.diff.id)}
              onMouseLeave={ () => this.props.diffHoverHandler(0)} >

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
