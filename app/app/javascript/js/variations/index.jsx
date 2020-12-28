import React from 'react';
import ReactDOM from 'react-dom';
import ActionContainer from './ActionContainer.jsx';
import DiffContainer from './DiffContainer.jsx';
import RenderableContainer from './RenderableContainer.jsx';


export default class Variation extends React.Component {

    constructor(props) {

        super(props);

        console.log('hi from Variation');
        console.log(this.props.data);

        this.state = {
            diffs: this.props.data.renderable.sortedDiffs,
            //used for height of diff & renderable scrollbars
            renderableHeight: window.innerHeight,
            bboxVisible: true,
            diffBboxHoverId: null
        }

        this.diffPanelRef = React.createRef();
        this.renderablePanelRef = React.createRef();
    }

    //handlers:

    //action -> toggle renderable set
    //hide action for now, but likely needed

    //diff onhover -> bbox diffs color
    //diff click -> bbox scrollTo
    //diff_id 0 to "turn off?"

    diffBboxHoverHandler(diff_id) {
        //console.log("diffBboxHoverHandler", diff_id);
        this.setState({
            diffBboxHoverId: diff_id
        });
    }

    diffClickHandler(currentRef, diff) {
        //setState clicked, toggle diff visible
        //bboxRef are set in BoundingBox.jsx, Diff.jsx on componentDidMount
        //key for scrollBy is to aim at viewport midpoint - innerHeight/2
        console.log("diffClickHandler", diff, currentRef);

        if (diff.newDim && diff.newDim.bboxRef.current) {
            const y = diff.newDim.bboxRef.current.getClientRects()[0].y
            const height = diff.newDim.bboxRef.current.getClientRects()[0].height
            this.renderablePanelRef.current.scrollBy({left:0,
                                                      top: y - window.innerHeight/2,
                                                      behavior: "smooth"});

        } else if (diff.origDim && diff.origDim.bboxRef.current) {
            const y = diff.origDim.bboxRef.current.getClientRects()[0].y
            const height = diff.origDim.bboxRef.current.getClientRects()[0].height
            this.renderablePanelRef.current.scrollBy({left:0,
                                                      top: y - window.innerHeight/2,
                                                      behavior: "smooth"});
        }
    }

    bboxClickHandler(currentRef, diff) {
        console.log("bboxClickhandler", this, diff.diffRef.current, currentRef);

        const y = diff.diffRef.current.getClientRects()[0].y
        const height = diff.diffRef.current.getClientRects()[0].height

        this.diffPanelRef.current.scrollBy({left:0,
                                            top: y - window.innerHeight/2,
                                            behavior: "smooth"});

    }

    togglebboxClickHandler() {
        console.log("togglebboxClickHandler");
        this.setState({
            bboxVisible: !this.state.bboxVisible
        });
    }

    windowResizeHandler() {
        this.setState({
            renderableHeight: window.innerHeight
        })
    }


    componentDidMount() {
        window.addEventListener('resize', this.windowResizeHandler.bind(this));
    }

    componentWillUnmount() {
        window.removeEventListener('resize', this.windowResizeHandler.bind(this));
    }

    render() {
        const diffWrapStyle = {
            overflowY: 'scroll',
            height: this.state.renderableHeight
        }

        const renderableContainerWrapStyle = {
            overflowY: 'scroll',
            height: this.state.renderableHeight
            //listerner: on change resize / smaller devices what is this
        };

        if(!this.state.diffs) return <div></div>

        //active/base_renderable.screenshot

        return (
        <>
        <section className="action">
            <ActionContainer {...this.props} />
        </section>

        <section className="renderableDiffs">

            {/*TODO: componentify*/}
            <div className="columns" >

                <div className="column is-full">
                    <h3> Renderables & Diff Controls </h3>
                    <p>icons, controls, etc. (e.g. text diff side vs interspersed) </p>
                    <p>place bboxClickhandler control here instead of img</p>
                    <p>TODO: make this a sticky nav scroll</p>
                    <button onClick={() => this.togglebboxClickHandler()}>Toggle bbox</button>
                </div>

            </div>


            <div className="columns">

                <div className="column is-3" style={diffWrapStyle} ref={this.diffPanelRef}>
                    <DiffContainer diffs={this.state.diffs}
                                   diffBboxHoverId={this.state.diffBboxHoverId}
                                   diffClickHandler={this.diffClickHandler.bind(this)}
                                   diffBboxHoverHandler={this.diffBboxHoverHandler.bind(this)}
                                   {...this.props}
                    />
                </div>

                <div className="column">
                    <div className="columns" style={renderableContainerWrapStyle}
                         ref={this.renderablePanelRef}>

                        <RenderableContainer diffs={this.state.diffs}
                                             renderable={this.props.data.renderable}
                                             bboxVisible={this.state.bboxVisible}
                                             diffBboxHoverId={this.state.diffBboxHoverId}
                                             diffBboxHoverHandler={this.diffBboxHoverHandler.bind(this)}
                                             bboxClickHandler={this.bboxClickHandler.bind(this)}
                                             {...this.props} />


                        <RenderableContainer diffs={this.state.diffs}
                                             renderable={this.props.data.controlRenderable}
                                             bboxVisible={this.state.bboxVisible}
                                             diffBboxHoverId={this.state.diffBboxHoverId}
                                             diffBboxHoverHandler={this.diffBboxHoverHandler.bind(this)}
                                             bboxClickHandler={this.bboxClickHandler.bind(this)}
                                             {...this.props} />
                    </div>
                </div>
            </div>
        </section>
        </>

        )

    }
}
