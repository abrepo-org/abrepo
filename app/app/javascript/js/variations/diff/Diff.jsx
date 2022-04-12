import React from 'react';
import ReactDOM from 'react-dom';
import DiffView from './DiffView.jsx';
import DiffViewMin from './DiffViewMin.jsx';

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

    getBboxLocation() {

        const currentRef = (this.props.diff.newDim &&
                     this.props.diff.newDim.ref &&
                     this.props.diff.newDim.ref.current) ||
              (this.props.diff.origDim &&
               this.props.diff.origDim.ref &&
               this.props.diff.origDim.ref.current);

        if (!currentRef) return null;

        const rect = currentRef.getClientRects()[0];

        return {
            newDim: this.props.diff.newDim,
            origDim: this.props.diff.origDim,
            y: rect && rect.y,
            height: rect && rect.height
        };
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

        const rectStyle = !(this.props.bboxHoverId ==
            (this.props.diff.group_id || this.props.diff.id)) ?
                          defaultStyle : hoverStyle;

        return(
            <div
              className='diff p-3'
              ref={this.ref} style={rectStyle}
              onClick={() => this.props.diffClickHandler(this.props.diff, this.ref, this.getBboxLocation())}
              onMouseEnter={ () => this.props.bboxHoverHandler(this.props.diff.group_id || this.props.diff.id)}
              onMouseLeave={ () => this.props.bboxHoverHandler(null)}>

                { this.props.diff.viewMode === "full" &&
                  <DiffView diff={this.props.diff} detail={true} {...this.props} />
                }

                { this.props.diff.viewMode === "diff" &&
                  <DiffViewMin diff={this.props.diff} detail={true} {...this.props} />
                }

            </div>
        );
    }
}
