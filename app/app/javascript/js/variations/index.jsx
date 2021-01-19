import React from 'react';
import ReactDOM from 'react-dom';
import ActionContainer from './ActionContainer.jsx';
import DiffContainer from './DiffContainer.jsx';
import RenderableContainer from './RenderableContainer.jsx';
import MobileModal from './MobileModal.jsx';

export default class Variation extends React.Component {

    constructor(props) {

        super(props);

        console.log('<Variation>', this.props.data);

        this.state = {
            diffs: this.props.data.renderable.sortedDiffs,

            //used for height of diff & renderable scrollbars
            renderableHeight: window.innerHeight,
            bboxVisible: true,
            diffBboxHoverId: null,

            mobileModalIsOpen: false,
            mobileModalContent: null
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

    mobileModalCloseHandler() {
        console.log("mobileModalCloseHandler")

        this.setState({
            mobileModalIsOpen: false,
            mobileModalContent: ''
        });
    }

    bboxClickHandler(currentRef, diff) {
        console.log("bboxClickhandler", this, diff.diffRef.current, currentRef);

        const rect = diff.diffRef.current.getClientRects()[0]
        if(!rect) {
            //if diffs are hidden rects are null
            //launch modal or tooltip or something
            this.setState({
                mobileModalIsOpen: true,
                mobileModalContent: diff.id
            });
            return;
        }

        const y = rect.y
        const height = rect.height

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
            renderableHeight: window.innerHeight,
            renderableWidth: window.innerWidth
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

        //toggles off scroll on mobile is-hidden-touch
        const renderableContainerWrapStyle = this.state.renderableWidth > 1023 ? {
            overflowY: 'scroll',
            height: this.state.renderableHeight
            //listerner: on change resize / smaller devices what is this
        } : {}

        if(!this.state.diffs) return <div></div>

        //active/base_renderable.screenshot

        return (
        <>
        <section className="action">
            <ActionContainer {...this.props} />
        </section>

        <hr />
        <section className="renderableDiffs">

            <div className="columns">

                <div className="column is-3 is-hidden-touch">

                    <div className="columns">
                        <div className="column is-full">
                            {/* not sure controls should be sticky */}
                            {/* diff control placeholders */}
                            <button>text</button>
                            <button>css</button>
                        </div>
                    </div>

                    <div className="columns" >
                        <div className="column"
                             style={diffWrapStyle} ref={this.diffPanelRef}>
                            <DiffContainer diffs={this.state.diffs}
                                           diffBboxHoverId={this.state.diffBboxHoverId}
                                           diffClickHandler={this.diffClickHandler.bind(this)}
                                           diffBboxHoverHandler={this.diffBboxHoverHandler.bind(this)}
                                           {...this.props}
                            />

                        </div>
                    </div>
                </div>

                <div className="column">

                    <div className="columns">
                        <div className="column is-full">
                            {/* renderable control placeholders */}

                            <button className="is-hidden-touch">double view split</button>
                            <button className="is-hidden-touch">single full view</button>
                            <button onClick={() => this.togglebboxClickHandler()}>
                                Toggle
                            </button>

                        </div>
                    </div>


                    <div className="columns" style={renderableContainerWrapStyle}
                         ref={this.renderablePanelRef}>

                        <RenderableContainer label="Variation"
                                             diffs={this.state.diffs}
                                             renderable={this.props.data.renderable}
                                             bboxVisible={this.state.bboxVisible}
                                             diffBboxHoverId={this.state.diffBboxHoverId}
                                             diffBboxHoverHandler={this.diffBboxHoverHandler.bind(this)}
                                             bboxClickHandler={this.bboxClickHandler.bind(this)}
                                             {...this.props} />


                        <RenderableContainer label="Original"
                                             diffs={this.state.diffs}
                                             renderable={this.props.data.controlRenderable}
                                             bboxVisible={this.state.bboxVisible}
                                             diffBboxHoverId={this.state.diffBboxHoverId}
                                             diffBboxHoverHandler={this.diffBboxHoverHandler.bind(this)}
                                             bboxClickHandler={this.bboxClickHandler.bind(this)}
                                             {...this.props} />

                        <MobileModal isOpen={this.state.mobileModalIsOpen}
                                     content={this.state.mobileModalContent}
                                     mobileModalCloseHandler={this.mobileModalCloseHandler.bind(this)}
                        />
                    </div>
                </div>
            </div>
        </section>
        </>

        )

    }
}
