#!/bin/bash
# +------------------------------------------------------+
# | Author: Diwayaa                                          |
# | Region: Indonesia                                        |
# | Chanel: https://t.me/tunnelstores / Admin  @diwayaa  |
# +------------------------------------------------------+
skip=56
tab='	'
nl='
'
IFS=" "
#This script was encrypted by @diwayaa, if you experience an error please report IT
USER=${USER:-$(id -u -n)}
HOME="${HOME:-$(getent passwd $USER 2>/dev/null | cut -d: -f6)}"
HOME="${HOME:-$(eval echo ~$USER)}"
#This script was encrypted by @diwayaa, if you experience an error please report it, for anyone who describes it please tag me, the code was created by myself with the help of the internet, not taken from someone else.
umask=`umask`
umask 77
shctmpdir=
trap 'res=$?
  test -n "$shctmpdir" && rm -fr "$shctmpdir"
  (exit $res); exit $res
' 0 1 2 3 5 10 13 15
case $TMPDIR in
  / | */tmp/) test -d "$TMPDIR" && test -w "$TMPDIR" && test -x "$TMPDIR" || TMPDIR=$HOME/.cache/; test -d "$HOME/.cache" && test -w "$HOME/.cache" && test -x "$HOME/.cache" || mkdir "$HOME/.cache";;
  */tmp) TMPDIR=$TMPDIR/; test -d "$TMPDIR" && test -w "$TMPDIR" && test -x "$TMPDIR" || TMPDIR=$HOME/.cache/; test -d "$HOME/.cache" && test -w "$HOME/.cache" && test -x "$HOME/.cache" || mkdir "$HOME/.cache";;
  *:* | *) TMPDIR=$HOME/.cache/; test -d "$HOME/.cache" && test -w "$HOME/.cache" && test -x "$HOME/.cache" || mkdir "$HOME/.cache";;
esac
if type mktemp >/dev/null 2>&1; then
  shctmpdir=`mktemp -d "${TMPDIR}shctmpXXXXXXXXX"`
else
  shctmpdir=${TMPDIR}shctmp$$; mkdir $shctmpdir
fi || { (exit 127); exit 127; }

shctmp=$shctmpdir/$(basename "$0").decrypted
case $0 in
-* | */*'
') mkdir -p "$shctmp" && rm -r "$shctmp";;
*/*) shctmp=$shctmpdir/`basename "$0"`.decrypted;;
esac || { (exit 127); exit 127; }

case `printf 'X\n' | tail -n +1 2>/dev/null` in
X) tail_n=-n;;
*) tail_n=;;
esac
if tail $tail_n +$skip <"$0" | gpg -q --decrypt --batch --passphrase "diwayaa project | TI::yk::HI::sk::65::W1::88::mT::A7::DH::un::oF::nI::VX::7Q::R5::BN::xa::T9::XG::hz::Ys::i8::5m::z5::K9::Hz::pE::7r::bq::Bc::qE::3A::Yg::tr::XB::6P::3E::IA::cK::u3::e9::0T::tF::TE::5r::cv::YS::CM::sK::Vf::iA::0f::Tv::gb::Qw::aH::UX::As::g1::uh::WM::Em::d8::1y::oP::gO::7w::ht::Mq::Qk::9C::Pr::81::VZ::hj::SG::fK::gP::7M::R1::24::I3::1U::rS::jf::Xb::ig::z4::Z7::jl::Zu::nZ::CX::9o::uU::Xn::LM::VX::pb::LB::LQ::8j::kz::Se::2A::o4::Wj::lE::pL::G0::Fv::xA::DA::3k::Xl::VM::0l::Hx::BG::ZD::zE::Qd::yZ::0u::3u::M6::i4::5d::Eo::KS::nz::6L::nd::YR::aj::OL::EC::Kk::3q::xq::Zt::ZT::Js::20::S9::A4::Kp::8q::6L::Xp::Ua::AS::OC::6i::10::tG::T0::QI::ds::eH::ii::Y4::Jo::E7::qZ::l8::xz::R2::GC::ft::uY::vC::2L::T9::YX::EV::mn::RP::pC::oG::Gy::Yh::iz::mX::TB::1A::ER::ym::CM::yQ::bF::bv::SB::d5::9b::c8::3Z::BL::tw::ma::2S::Ok::xu::qR::im::HF::R9::Oy::l8::UD::kc::OG::ty::ey::Vm::iL::jG::AO::PL::PM::OS::Ce::lv::gc::sh::Ve::MV::N6::AY::Ds::Lc::Om::ol::Cd::Fq::ZO::rs::5M::EH::J2::8j::HM::0y::W7::H9::2b::bH::u7::sf::wX::H3::qS::3S::8m::UE::vN::3j::ir::LA::vP::ts::iY::6D::9X::V7::W4::jr::Oz::ue::R9::LG::Li::r3::ad::OS::4z::di::ec::7h::dr::no::1a::o3::HL::7l::Dy::89::Sw::uV::0a::JJ::wj::HQ::Yf::GZ::E6::R3::NZ::ix::Y9::Qm::fM::Th::FX::DM::a6::gq::vk::Fg::yF::9h::rp::1O::xE::Bh::fl::4a::cO::Gp::Qv::I7::zi::id::s7::Vl::G3::l5::Mb::5r::DB::J5::kQ::eK::So::s3::Ja::1t::nD::Gg::iq::IC::DG::S5::yI::XH::Y6::xw::0u::Lp::tn::bR::ec::Vy::4l::aA::j8::ML::nv::vz::I1::HR::vn::cZ::MG::rb::NS::LI::9X::KR::vl::S7::TT::2n::00::tx::wn::AI::XI::CO::LS::uD::Df::5V::sx::2f::El::hy::AB::XA::Qc::Gd::aE::yW::Qb::bJ::qi::gh::Pm::ZT::Ck::T1::kz::Kb::od::3L::HU::2j::bo::dV::YF::cK::SB::Fh::Y6::1Q::Vx::09::yF::xN::DO::DU::QU::bM::si::4m::jH::KO::wj::Qx::40::J1::pL::PS::gY::WF::je::4b::u1::9c::nf::BL::ZT::Ni::NO::SY::dC::vx::O4::fG::G2::4e::Ut::hj::9i::JG::Vt::BY::oW::0Q::1y::q4::GP::bJ::CB::UC::jy::7b::Pl::dl::rc::WO::VB::xa::or::q4::x6::n0::wU::bC::7n::IO::rg::Wh::3u::3B::Yl::1H::w9::g1::IF::A0::pY::bD::ug::Ax::uk::qB::SU::BO::2j::0B::FH::8Q::IO::tu::yA::Qv::r9::SO::XW::ja::1B::p8::VA::pK::RX::TD::7D::Gz::Ws::Ky::Mk::Va::7J::lU::Be::5W::e7::Yg::CH::bl::2X::lA::65::MX::Fk::sw::gn::HX::40::7b::9W::kA::yn::qf::7z::WW::vs::bN::RQ::8L::yy::tZ::Rx::Cp::vw::VJ::Zz::B2::kn::TR::5x::it::Xx::rt::dR::RE::mJ::BS::Mn::Qk::8u::28::VZ::lL::OX::Td::LO::MR::bW::1i::ME::f0::pz::Xn::tx::TV::6k::sN::as::9L::Ip::6O::od::eW::jW::km::2k::JJ::22::b8::AT::hW::Uj::4h::Iv::vD::gC::iv::g8::l4::d7::CE::tX::0g::pG::pi::Fh::gs::VC::49::af::VN::2N::TB::GW::0H::P8::0x::4H::t1::pJ::5z::8M::3I::pD::6R::kR::FU::ft::fa::ow::u0::JV::81::te::sA::LF::S8::kG::p1::bm::n6::BU::PF::aI::Us::KL::zy::GE::mM::nd::mp::sZ::B3::pa::Il::Dd::cI::oQ::3U::jF::pZ::t4::Bk::YO::sG::ci::zu::Dc::Th::Gp::vO::wP::7a::e8::jn::bm::1x::mt::KA::Tq::zC::H5::hb::oJ::9V::Vz::9R::ob::lZ::jm::Pv::LI::ne::Ce::Ic::Lf::NF::Yn::DI::kl::cS::69::9y::kU::yH::SA::eC::Qr::3N::i3::Zq::6l::pT::dI::Lp::kt::pw::A2::PS::Cm::73::zo::Wy::9U::VX::zh::6F::Bx::M1::kr::gx::ou::0C::6l::2p::nP::Mn::31::K5::a0::N1::Ni::BQ::HL::nX::qT::wm::5G::1P::sp::bB::Bj::vs::fG::ON::c2::YV::NI::jX::cF::ZR::az::JD::Qx::MS::Wr::vf::om::8C::BC::c9::1g::DV::iq::ui::VE::8z::0E::U4::34::Uq::k1::fN::Sl::PT::Rl::D6::QT::tw::j5::FO::Nl::R0::PY::0B::r4::o3::jX::LM::wI::oW::au::Cn::Rz::48::Vm::9J::S5::DF::vC::lb::CW::dg::Vk::e1::Nh::ob::Q6::9G::6l::sB::AX::zO::rl::su::Yf::ob::oD::vh::x1::pD::Sh::L8::NH::i5::Yb::6q::pa::ht::Td::LT::3r::Uo::gS::2g::xj::fe::M0::8e::7F::Ab::rt::Mh::ki::UC::z2::CK::cB::Ta::3Z::wn::ua::Ai::W4::yj::F6::bS::DZ::75::VS::qP::bN::t5::jF::hN::Ii::Sg::K3::G9::sv::GA::f6::xS::7Q::wJ::m0::p3::86::bA::sH::e1::Le::Ei::cO::Ek::CZ::dr::OG::ky::Fx::km::lg::z6::G9::yp::S0::ZS::1r::Jk::rd::L6::C1::aa::9Y::Do::7j::2x::Za::d0::Nc::JE::ud::v5::i5::3v::NR::3z::7B::Xv::o6::e0::sY::Kn::P6::H8::Yg::k2::Eo::1D::BF::pJ::y3::XX::IR::Ig::IE::aW::Rv::j7::cW::uo::a0::Ru::6n::tB::Cd::Bw::9U::O0::hc::AM::ty::CL::EV::pW::P3::l1::wT::gH::v5::vd::Aw::to::pl::SY::aE::ox::gl::fi::lV::Ug::Kr::Zx::o1::hj::XJ::Cv::kA::qJ::oP::KM::VP::lO::aW::C4::5a::mZ::ob::XX::S6::iw::xn::tN::6D::50::0r::Xb::sa::Ap::f3::cU::uO::zM::sS::Pr::4u::3L::FN::E7::6U::ir::uo::xf::f2::Hn::MU::wc::4l::sk::yA::RW::c8::KA::oB::EB::Ep::lY::XK::0i::yp::Fy::jK::3X::Zw::Se::wG::DB::Z6::bb::Xq::jg::x4::lS::Z1::8G::x4::0Z::LA::za::fZ::23::21::xU::cw::YG::zP::Jc::6u::4F::k8::aq::6F::xD::NL::JU::VJ::pT::qd::gt::9w::qZ::bX::FF::Rf::bA::vD::Hq::Ph::0j::96::q2::SW::qg::Xw::t0::jm::fl::2N::M3::MR::3e::da::so::Xb::tC::h7::0L::u3::l0::ok::CA::OQ::dd::EC::vC::mw::R5::x7::uU::1g::xw::rv::s0::jr::hc::J3::uA::X9::5Y::wS::2v::kR::x8::jn::CQ::Pa::fU::qU::JN::iE::JN::Ph::Gx::dc::eb::vP::wL::g9::pw::cd::Kd::gK::Kw::8c::Mb::rH::r0::D9::48::1V::dn::6s::js::we::Yy::4Z::JA::bd::ig::Di::2O::lq::L1::Qj::wO::m5::Of::gY::zB::cx::Vf::Ep::bD::i8::11::bu::Rm::nb::I3::cD::NZ::EC::oY::cf::P3::qy::m1::mn::ui::S0::4o::EA::Yb::HD::MT::95::dg::jb::x4::yz::uG::ee::b8::G8::lh::c0::Vj::rz::Ep::74::ye::Kq::gz::p1::WC::lk::Ih::QI::p2::no::c4::tS::Mz::JP::lU::bR::Lh::xD::HQ::LM::ez::EB::bC::In::YF::Cv::Cv::v6::9H::Or::Br::Ey::xF::SQ::1w::nP::X8::54::1H::7m::c4::lS::zl::F7::v6::ZJ::Fc::iA::EL::Em::8A::rg::QV::3E::j8::CB::P7::Ga::1O::CO::LK::tL::k1::e7::Ev::6y::8s::LM::gx::UJ::SR::Bg::4o::qt::0v::EZ::n1::Km::3X::YV::hM::T3::ar::5i::cr::I5::Sg::fj::pX::dW::WV::3y::gO::Sv::s3::I4::AA::LX::gW::V0::Ub::tq::ei::lB::b1::VM::at::SU::Wz::60::dX::E3::SV::zj::vl::rg::IR::0b::2x::nE::Rr::1C::Jr::iL::vH::p7::2I::vW::Wa::5s::BT::W9::LX::yi::q2::Mh::k9::Fh::1E::ly::k3::s5::vg::1m::kM::6s::ag::Ad::k7::7K::jP::FE::vI::8n::jr::7x::eH::Zk::cH::8p::d6::nA::fO::RP::l2::vI::QM::sT::el::mh::fQ::K0::ew::gF::o3::bw::FT::wk::47::Vt::gJ::kx::RY::pe::c2::2n::eE::df::ws::EK::hB::57::XN::ku::hw::lP::bC::EY::bw::rA::5b::Kw::GF::tj::cy::HK::ps::XF::kU::A9::hr::EK::IL::6l::6W::SE::YL::Pw::C2::qT::we::fO::Dd::Um::QU::ma::rw::pG::k4::HI::Vg::Cd::gX::zV::88::RW::dS::VE::03::WW::zv::Hj::kZ::Lb::tb::7v::qD::Xm::P2::6y::cp::P0::1y::Xg::9k::5D::W8::aU::f3::7y::lI::Os::MI::wa::w5::GY::uu::Xd::Kn::HE::X7::I9::ap::pX::4l::EQ::k6::bJ::WC::io::qw::GQ::GN::WV::eC::UU::gR::Sr::Jp::Ir::QW::ww::Ua::l5::2L::1H::HZ::6t::Ry::h1::kP::U1::vb::xt::FJ::u6::ti::RO::Wc::1S::Ui::il::my::9Y::jL::Jn::zc::oM::pg::bf::Ha::zC::Jj::YS::A1::e1::JG::EX::Wd::JT::Eo::uU::vx::i6::Ln::Ze::8x::QL::1t::ua::Ub::M7::3y::Is::br::vA::iE::pX::MZ::RJ::MH::wy::CA::6r::gg::zc::QU::KV::ow::yQ::Gv::ns::7J::HJ::JX::a4::rs::Yl::mm::w0::iz::SD::60::1A::Q2::D7::0M::yv::3M::1m::MI::tW::sO::7s::ZA::iU::No::Ha::WD::WO::Sr::1e::wW::5m::tP::JF::GX::2v::YJ::O2::79::a4::4q::sx::98::ca::G5::7o::Q0::vd::k2::jL::HN::GL::Gq::1V::1G::9x::aj::z9::bM::9Y::ts::Zi::5v::q6::Se::m2::ik::Us::vq::En::S7::mC::in::b0::Or::wU::ky::CV::QL::FO::5J::Ck::iZ::Nu::JT::UB::v0::Zx::Ez::GS::H2::ZS::Jj::V7::uB::IH::2E::td::IN::Wm::5B::Mc::j7::UP::eq::5E::UV::DJ::6P::5t::wE::Y9::0j::5A::mD::LR::00::fj::bR::7H::hp::ix::tK::xq::Ui::Pr::WN::Xk::mQ::Tg::Ri::fG::d5::eH::qa::7U::VH::wM::OM::p0::2c::5q::yo::Ed::Qg::ct::9S::Z2::RO::hp::8J::Vm::gh::qI::4C::oV::5F::JZ::up::lV::rE::ub::nR::rY::H6::ta::cf::45::zr::hG::J4::qq::Th::kn::Cb::zT::gn::aH::Nc::jR::EU::Vs::kZ::8k::YA::EF::6J::yM::3Q::Zs::Jr::9f::3M::7Z::g7::Zk::Lj::41::lt::eY::2J::KW::cH::mK::As::8a::lK::RC::CT::NW::yS::q7::GU::Bg::Xm::Wk::M9::kt::bT::UI::Wg::dN::2j::IL::Qu::EG::Ql::rR::RR::3v::9q::zl::mD::Q4::SK::FD::ko::3V::D8::ac::vc::Xc::nm::fu::mk::st::de::jt::ZZ::CF::Q3::hC::NR::1j::FG::89::Fh::DO::dx::WQ::gF::V1::m8::Qf::DM::ew::VD::St::ba::Ww::6E::ZI::Mj::WL::0m::fb::Ci::wq::e2::qd::fZ::m1::27::OC::Cl::bJ::Rk::Nb::yo::iI::0d::0S::sW::kd::sn::sY::kV::A0::mZ::RI::Kt::Nb::Le::OK::I6::o8::cl::y5::YL::vv::2W::az::Uy::Ye::ls::H3::uG::0G::ad::KL::BQ::ZE::CR::ds::KO::3N::cD::Jy::6k::GS::1l::GI::JD::UV::Y5::PL::bh::6p::DV::H3::hE::Ej::QN::kB::rP::9i::nQ::3G::FW::sM::rX::Ou::0h::yh::B1::76::aT::fN::4q::oK::l0::8f::wJ::UU::I5::g7::2j::UT::vK::g2::4m::s6::yG::44::tg::jr::jp::Pu::7f::qf::5o::uL::KZ::Tp::zb::zX::OT::dB::aN::vY::FL::H4::rP::ru::Qt::MP::0v::MQ::6S::a2::CU::bL::bz::yQ::uC::Y7::sc::OF::xD::w6::57::wQ::67::ea::jn::Lz::zE::ZH::jW::fa::jg::QM::R0::en::M9::Er::nD::UY::nK::j6::yI::8Q::20::19::6H::Ji::ah::Nf::k9::XI::9d::vQ::zH::vt::hs::6Q::F1::ar::Fh::FL::8q::ib::97::WT::0r::66::9g::PZ::0e::no::qB::Yq::Wb::7f::rr::st::vj::f0::IS::AX::4j::Bw::M3::lR::xw::2T::GT::kv::XI::rK::Wa::id::om::JQ::8J::s8::wR::cF::H8::oA::cK::gU::0L::oi::La::IG::0I::uM::Uw::bF::TH::ZF::h5::MM::xF::tv::7H::Yb::KG::0K::rI::B4::Nr::bB::ZM::v9::Ya::1S::VA::vF::hh::RW::E1::ba::uO::Jz::AP::Jk::IA::Fj::yW::J1::ah::Rf::VJ::Ac::mW::cJ::kA::eE::OI::7J::Fe::PC::mp::B4::UI::jV::Ze::iw::Bs::hP::EO::pM::fR::xg::4o::uZ::a6::CE::sH::EY::Xz::1n::Qs::wV::9g::n2::rh::y8::FE::oj::x7::7L::a2::uK::fz::hN::mp::h6::Ae::0R::M2::c4::0N::u8::1i::qT::t0::BW::HY::Hz::q2::2F::aY::fg::WR::Ew::cI::wY::QY::YJ::t7::2V::U6::bE::LS::Lh::UG::3I::ts::dK::NC::Zp::X3::ZM::QG::yB::Ah::3E::BE::x3::OM::QO::bU::pj::Va::JY::2y::5V::vA::6B::Nw::5N::FO::W5::Wp::rs::0C::6R::oT::pT::p6::En::2r::cG::n0::HL::Im::B8::BM::k3::fQ::cT::yA::Fd::Pr::XX::B1::uA::1L::Iz::DY::x9::zQ::tA::9j::JJ::ze::Bq::B2::Xh::Rm::Qe::zZ::WS::Eu::Vd::5y::HC::Tr::E8::sZ::3d::Dv::Li::ok::qJ::q2::Kf::6w::ZE::rL::fv::pJ::Vw::B7::7T::80::Vh::ER::wf::yN::j1::wm::Fn::nR::QR::Hg::oV::7j::ci::cf::9a::or::lm::4l::uF::yE::om::7R::cT::c8::cv::zX::dn::Iv::fj::Oz::nS::1H::5q::QD::eZ::bH::mQ::c8::bn::YE::2i::pN::z9::UX::Ef::qZ::Ex::Zp::U5::Jy::r1::db::lt::hH::sU::my::Z3::VA::Mw::7O::tT::Pl::SC::qF::II::Q7::7U::Tz::uO::kH::08::Oc::o3::2W::gZ::vO::6c::Rz::3W::ro::SE::kN::CO::jy::sf::fg::fC::nO::Cf::Ey::KB::i8::7A::Ub::p3::nD::Lu::Sl::Nj::X1::8i::k4::hL::QP::OQ::9J::wU::xg::jz::lU::hf::2D::TY::gu::al::WI::pH::vi::7n::sJ::1U::Yu::vb::jd::1p::PP::V9::sy::wx::x5::pG::Ub::8G::cf::Bi::Ft::yv::ye::kZ::Az::3q::JZ::Fj::rj::li::Sm::HP::nV::ol::mH::wj::M3::u0::2V::fs::EF::Tf::wU::42::13::Ci::Q9::R6::mt::31::he::UX::Ub::rY::mY::0L::QN::zF::0r::Jw::Af::cD::c0::v5::H4::YS::1u::6e::Dg::4h::3g::k2::V5::bA::bO::gv::lE::Ce::j0::ol::UX::P6::qG::FU::xA::Ur::2R::5k::KS::iF::H1::oU::Jk::6P::WL::KP::yH::HM::3K::kw::4P::HK::Xa::bi::Zm::17::cM::gD::4f::y5::en::CR::Il::gq::g2::z2::Fb::P9::kl::jH::5T::3T::aL::Rb::Jx::wR::SO::Bw::1m::Ke::6s::JV::tK::l1::rF::SQ::rP::gJ::Fa::fe::f6::VV::JF::QB::Cf::Xd::I8::Om::VB::A1::XN::OZ::Z8::zf::vx::Dz::km::Kc::IS::5p::GR::wy::Nk::pW::7O::mJ::u7::3u::kH::KW::eY::s8::Ky::tC::bi::QP::wL::bX::gu::uN::FW::Xf::2p::YN::Tm::pZ::wz::Fg::Ep::6H::Dm::nC::NL::U6::jv::BX::3C::U0::t3::Qk::vV::ou::wF::Td::Em::vP::oQ::bE::89::Vw::nA::ay::Fm::gb::Yv::z5::yy::tP::AQ::8h::50::kn::fX::up::yE::f2::Os::c8::RV::XJ::E5::Ep::Jh::Cc::s5::aK::Ze::Ss::Sv::jM::YY::3v::7x::Zn::6L::YD::bV::YF::HJ::Rh::vP::d8::P9::Ju::Od::8k::ta::vD::fh::3z::Fg::M5::8L::AX::Km::iy::af::Mb::2a::8R::IT::VK::v6::zs::p2::sa::i4::AY::xE::nJ::SN::8A::lJ::8z::6J::NH::3a::UG::Nh::m5::xp::cg::ut::iD::aA::0H::Zs::1i::f2::Ez::kB::BA::UU::dF::t1::DX::9Q::CD::bc::wK::l0::I8::82::4P::fO::f9::Jr::Lj::tq::Yc::2u::LP::Th::0R::M9::Bz::Zo::at::FV::q9::JS::gB::lb::x6::6C::Tc::34::Rv::YO::aU::Sq::hz::dn::Sg::r8::9f::ow::Jm::XO::qF::ft::rh::EY::IA::Ta::wc::sG::MV::vx::nM::Hh::15::BY::hz::m8::uv::kB::3T::fV::dY::pg::2g::NI::HI::hX::nS::DM::lz::XI::wV::fm::XI::dx::vb::Bv::Kz::oc::ax::58::cw::CV::p6::Y8::Lu::WK::qN::C4::oI::H7::Hi::W3::fe::vI::HH::s9::qw::80::8I::Ft::5t::7Q::gV::Kx::HO::8c::cw::kK::bV::Dw::el::au::ok::E9::Qn::74::2u::2W::24::1F::3Q::5Q::6o::9t::fR::1o::Ep::hT::ya::jl::9M::Vp::k2::og::QM::IG::lI::Ph::S5::q4::pX::Jr::NU::R9::Ra::SW::LK::KP::vZ::5Q::uV::Bt::p1::vV::vC::ds::bO::Mz::64::6E::6o::7I::r9::va::Pe::dP::nL::ym::KE::Q8::2c::Mx::AX::7i::Cp::ID::uH::oB::WG::Zz::yZ::fe::w8::8f::az::pm::1o::4b::hw::Pc::G8::3Z::6N::O6::1v::1a::at::52::2Q::Yv::z1::4i::Y4::QB::0F::Qz::lS::Q5::79::IN::tN::N3::Qt::br::rk::xa::mT::uy::Qs::Tx::Zk::i9::oc::sZ::IT::Hi::TC::mQ::Ds::2f::bc::qt::qa::gw::Rt::Tg::Fu::KP::aQ::iM::aF::dp::9D::E0::qs::gY::VH::iX::ux::7V::Z1::yI::yM::v8::pS::ga::Gq::tZ::3w::qf::ZR::UG::Ig::Kt::zs::ui::iV::xZ::Hp::Yk::9D::81::0J::gk::tt::rA::zi::nl::3t::qD::DA::W0::rU::vx::DD::CC::bC::eD::vl::Mi::ly::At::BH::q7::7I::3y::Cm::1A::2W::uw::BB::Sr::K3::Z2::2B::UC::5l::3i::de::ow::1r::ZE::tR::21::Fk::dV::As::uZ::D8::h2::Np::bY::6c::ZY::Vi::Wj::zH::MD::j6::hO::Xp::tj::S5::Sy::S0::px::Kq::KA::vf::dA::pj::F5::bf::pw::0w::4L::25::zy::dE::UC::94::hm::lg::Tb::1k::DM::xj::cQ::oB::dQ::ab::8R::Lt::sH::gP::hb::m0::Yz::ED::mL::6l::1c::6y::24::K0::VV::D8::BC::xf::Zw::O8::K4::BA::rj::Cm::QQ::XU::9O::qQ::v3::Xk::Gt::P7::mx::qL::N4::5F::0G::Lb::rv::8c::Bk::D5::yE::3Q::fi::d9::pZ::XJ::i8::k4::YW::wn::eM::Bb::J2::15::cs::Bu::qW::eA::BN::Uo::Sp::3B::02::vJ::7F::2R::Ei::DF::iP::KY::4G::34::lz::OK::vB::by::7q::rH::Hp::KF::GM::DJ::5W::Mc::jb::yw::Yv::ix::N1::Q5::jH::tp::M1::RQ::jC::oq::d4::nH::h9::5L::Wf::Ts::Ym::mF::Ei::xm::p9::Sj::U3::ff::sR::C9::9s::zx::5l::PW::6p::Bh::YB::VL::IF::fi::H5::Hb::4j::i8::VP::1Q::cB::TH::LW::iD::j0::WJ::N1::cW::FS::81::n5::4q::Fe::IV::Tu::OJ::nL::NK::37::VF::23::l6::zq::hb::Ak::dL::dx::UN::08::Es::5w::LA::29::gH::gt::4T::Yi::ET::Rd::k4::7R::bO::TI::zW::JS::TN::XC::eF::aA::bQ::58::iq::9h::jI::7R::HS::4g::4m::AO::C3::NE::xF::Ge::iP::8E::1T::nI::zg::WE::y7::An::zf::3K::0L::zo::mb::lq::6O::R5::q7::Uh::wo::oN::6A::co::0x::cK::Mw::Lb::Wd::Ub::01::EQ::sM::PY::qE::jN::Zh::Kw::V0::8S::4w::vi::jP::Jv::RH::bG::7Y::In::cd::Wh::bO::Jt::2u::ic::dQ::Uq::JT::8b::fp::Av::8h::6z::Yb::Fs::9H::Nw::sq::jx::vN::m2::kB::Ow::CP::4d::Lp::kS::xS::Y7::Yi::Rx::C6::vh::t1::UW::oz::yk::b7::g9::WD::m8::Sk::ue::2w::rN::bj::HX::IS::yi::G3::z9::Pw::lt::Qn::VZ::XE::z1::oJ::on::Zr::Qq::Sv::Cl::CR::tW::RH::rL::ud::o9::PP::ZM::9Q::0M::Pc::G5::nl::H0::KN::bM::kS::us::fb::RF::Hv::et::9s::Nr::We::gH::9e::x4::OJ::1z::OQ::ix::Jd::SA::dq::nA::Q1::jt::nP::Gt::xb::nx::AU::Hd::nv::JQ::rK::p2::nP::Pm::1S::Uy::Ca::Mr::Xd::P2::oz::y9::Xs::bt::Id::3l::id::Er::fF::f0::E2::aE::4M::ii::OH::6u::6N::CU::Xs::ta::8x::9E::Vb::0e::l5::3b::kT::Fi::Oe::vC::Mu::fR::DC::v7::K6::qV::zL::Ds::Ug::Fd::uD::dv::0L::VS::sd::eN::2K::Sy::N5::qw::v7::lA::oZ::cE::eH::0a::yv::xs::m8::BR::aB::To::LK::Ze::3G::Mz::iT::Fb::M6::Hf::tC::JC::Wr::sM::H5::It::G0::Lo::VR::vo::Jo::dp::7K::eR::Ni::md::XB::0n::hv::tx::jz::TU::uW::76::ce::Tj::r9::T0::uP::p4::WA::Jt::SI::jn::sB::7A::5I::Tc::T6::uu::h6::Wq::wq::ml::1k::S1::iw::n8::Ro::Jo::os::uc::6T::T6::Hl::xz::d8::Cs::zk::eu::u0::Tl::MC::CP::Eh::dk::fd::62::XX::O8::bE::vQ::zT::UE::4F::N1::eu::aQ::ID::7D::RO::TD::jJ::er::PQ::VB::tN::4l::Sw::Bu::aB::QI::mR::1c::YK::D6::ov::Aj::WN::OT::qF::0D::aB::bZ::5o::Jb::xm::A8::kx::ns::3Q::3t::jl::Ed::yV::86::Z5::A9::oj::rn::UC::tD::YB::cU::6X::CG::E8::6B::oL::Oh::j6::a9::cv::oB::x7::vM::LL::Ih::6N::89::K7::Jd::7n::Q0::e8::at::Qr::ar::tP::PP::1k::M9::cZ::lX::cN::88::XJ::ok::AG::2l::KH::fU::eu::Uf::LD::QD::tv::8X::vJ::nT::xk::hQ::ZF::Wz::5U::zZ::7F::ut::M4::rG::qz::im::A9::ap::DH::Z4::7G::la::DL::rq::Qp::VH::ew::iN::Hw::QR::B0::uW::4X::DV::uV::jY::Yo::nj::UM::ly::8T::1f::fa::uA::dZ::zE::bE::qy::vx::rv::P7::rV::LU::ru::lz::vh::2U::q5::8x::pB::iF::qM::5l::od::fj::l6::QN::OA::Jd::yt::yE::ob::KQ::VE::rj::hM::R2::X9::Tp::jl::5T::jY::Mj::Qn::Ys::jN::0C::gJ::KL::P0::7b::NB::Wu::fG::40::Sj::JO::k7::UX::bE::h1::SH::9v::U0::iW::li::Zw::p0::Nw::Sw::2d::VR::eF::Rx::Cs::bu::zq::Fu::Tl::SX::Ph::7u::iu::Dl::Pb::Ii::oY::M0::rV::ld::sT::eJ::fJ::Oq::jK::LM::dd::l4::2j::9D::EE::MI::dQ::WR::lg::Ti::tt::Uh::7C::TN::z9::xV::vh::3S::4u::Q1::0o::cJ::1H::v3::fp::H5::TA::4b::cZ::Pc::LT::FB::kc::a5::Kz::Le::iu::1u::Qu::5Y::cj::tj::uq::uH::hW::R1::Cd::wI::WK::5Y::Wx::Mj::A4::Id::4g::b4::ti::RE::EX::JJ::zD::24::6p::Jg::kl::EE::M2::AX::Tc::c2::Kd::Nh::iJ::mj::ub::9g::W7::a6::7l::X1::L9::Sq::Nc::xx::Dn::3q::UG::dE::ji::7u::Tk::Uh::63::VR::Ng::lx::4N::Li::nK::Tk::BG::8n::Hr::Lb::zQ::PH::SV::kQ::Kb::S0::fb::II::gW::cf::cY::FZ::AO::Fu::Hv::GH::QB::YS::3r::Vr::M0::85::l4::wc::He::nX::tx::kM::2o::Og::Mz::GU::l4::tB::cb::CD::3A::lG::J7::QT::l8::qc::wZ::lv::TP::Qm::25::uD::Vo::Wc::gH::oK::bI::xD::vj::QA::yg::8e::IF::S8::0B::Vj::pA::Zb::lm::2s::BK::lN::3B::6N::mH::xp::cU::F7::hr::lr::2I::LC::rO::WO::dJ::O1::kS::g9::tT::ee::O2::36::fd::oU::uY::j2::sj::YD::rX::xS::Ko::eh::gx::b5::Ea::Nr::E5::3T::uy::9N::Rz::7x::0r::jx::y7::HI::cH::sr::wT::w7::NC::84::9k::kz::XO::Cz::vG::GJ::fu::SW::Yi::gQ::aK::mg::ii::cX::z2::4P::uy::oE::ih::F6::yC::pX::VC::XZ::L7::uN::uT::Ip::bl::x0::Wc::dP::9n::oP::7I::ud::Cr::Pv::UH::l3::KX::sA::2l::ZD::Ov::1o::zJ::ZI::ai::F2::Tv::1z::RQ::P9::Th::t3::VD::5h::Na::T8::yz::vA::dd::ZY::5F::l0::Nx::qD::uW::HK::DI::cy::ML::K3::Pm::84::cZ::DY::Rs::8I::LC::Ly::fH::Fv::Ls::6b::aI::Ge::I8::JV::QU::kb::RJ::aQ::90::YI::zn::jp::XJ::V9::45::i1::Ba::N9::NH::9H::ah::mB::x3::an::h1::L6::um::XW::ek::nt::B7::r3::5Z::1w::E8::aO::zJ::98::Ep::i4::tS::sy::DO::yw::rP::6t::JM::bx::Y6::Vt::Ss::eV::dP::eG::ff::Fc::5M::ce::xH::VN::s9::F3::4v::qL::5a::8l::1L::3x::PE::aP::Py::WO::Ym::Rm::BT::vh::i9::7b::0o::t9::gn::t0::RZ::4p::D9::lS::Ek::OJ::Z0::MA::GQ::UQ::8N::7D::Wz::FF::8E::OP::U1::ZQ::4Y::xE::Z2::PC::vE::NM::Ct::FQ::Xp::z5::cJ::oD::57::IW::jo::Af::2U::1m::lA::7j::Vy::0Q::7s::Lo::oH::ze::p0::lq::Qc::ux::34::nY::4U::42::po::Xi::K6::fO::PI::Kn::Q4::7A::ry::mg::ku::Hr::M4::az::GT::B8::ce::6M::kl::Qj::zh::Vt::Gy::Oj::zq::8a::N6::kN::ln::qm::UM::he::p9::TG::5j::nl::2G::Oc::Ie::gX::gC::xy::Jc::WT::j8::kn::yG::of::tF::ar::gA::Hg::Xa::OT::uY::9P::fx::8O::Yl::CO::Qm::9F::TX::hW::Bs::jR::Sw::B7::c8::3y::hV::sd::hr::JW::a6::nV::za::P3::hV::jT::Gv::jl::v0::1n::wh::Qd::EZ::qH::VB::XB::0T::5X::vb::5Q::2R::ah::aT::OH::JH::fD::eO::cv::ge::fL::3z::O5::1Z::1y::1F::8P::6I::Qo::Ys::Mf::XX::uZ::FD::Ij::NS::Qo::zM::xV::wM::uH::v4::za::7R::Eq::a9::vv::Uh::be::tO::5h::NX::Em::mt::oA::wM::KA::X5::ar::33::u8::aG::7m::1t::zA::wq::lh::vs::Vn::ci::VJ::2W::CZ::Xl::GI::qf::rV::aU::8A::PR::w1::X2::93::TZ::Wp::s6::gi::CG::ZQ::5G::jM::G3::nJ::bI::u2::aV::qF::4E::R0::G5::jq::0q::ru::Nd::57::ut::TL::kl::fi::ea::0a::eb::eS::9f::HP::gp::Hm::3j::ph::xa::uK::Bp::nN::la::9y::zD::o2::fA::3l::oW::BJ::5b::Dh::Jt::Sn::nR::iH::74::yF::vY::Fj::8R::PL::S8::fk::5R::q0::sO::yx::Zy::4c::nh::Xn::vw::wJ::qu::nY::48::eX::Nd::7b::Fd::Ik::wL::6j::aX::VL::SW::zz::Xm::Cm::qy::Ox::kd::KC::Wr::1g::ld::dj::7P::W1::Kx::jf::Qs::AX::MP::cL::Mk::FO::Eg::wr::FA::5P::D5::pt::HS::gl::aV::uq::Hr::9u::m6::vE::Gt::5b::o1::ec::mw::cd::mZ::02::u7::Fv::jG::Du::Xv::lb::pS::Ex::pY::0r::T4::xW::AZ::ux::rS::GL::a2::MD::5H::OA::yS::HO::U6::0d::z7::W3::sU::CS::RX::Oo::L5::hX::Nr::Ns::N5::ls::86::gB::85::qr::qS::ac::8z::fp::U1::ph::EM::eS::J3::B1::0Y::ZH::gX::6P::4d::p6::Xh::Rn::yU::of::SG::Sb::VB::yf::cB::Uu::vV::oG::k7::PE::E1::6J::UH::Pu::oT::j6::iD::I8::gU::cn::g8::dQ::TD::aI::QT::Z5::ug::JX::N7::WC::nc::sc::5g::NE::py::LA::XT::Z2::yX::uM::J3::hC::aG::9h::vQ::Ob::mA::Pl::Aq::YI::ro::8U::zV::e7::Lr::75::NH::NF::JJ::SN::1d::90::hX::YK::qp::pl::9s::fE::xg::39::xv::kx::8w::Ei::4H::EU::yb::Hz::8t::lR::uM::JZ::AR::Hf::AK::gH::rG::Aw::Cl::5w::dh::dQ::jy::Sl::sT::aL::u0::pk::H4::lU::0R::rC::89::3b::PJ::wy::8n::zE::L4::us::ez::Ex::fD::Ar::OL::QJ::Qn::xZ::4E::RP::VN::hK::Pf::FQ::j0::kI::Vg::7X::Jm::h9::B2::rf::eV::ez::nO::ja::DD::Km::jp::RR::qd::Vs::RT::3O::DT::vs::lh::mc::Ht::Xq::01::qW::zV::yB::3B::35::ic::eX::KD::po::c7::Ya::Ap::S4::oF::2u::HH::7m::W7::Qu::te::Kw::A8::HP::fW::td::Rt::34::sz::Hg::ls::cL::Br::mM::zU::8o::xu::fT::o7::3b::S7::lM::AW::wu::lH::ka::Jm::8e::bO::Gv::b2::QW::k9::5R::H2::8B::3p::WC::XS::KR::pb::hP::Zu::sp::CG::4a::KV::Pd::eb::mY::Zh::jH::MA::fK::iv::hs::sV::pZ::jg::B7::0H::TW::YF::Pb::hu::fF::Dy::nb::f0::mO::PO::rU::2E::ks::OG::8g::33::4x::sB::DG::qq::f9::fe::iP::yz::y4::rB::OU::HM::ug::VD::Rp::X1::CY::AO::33::Sf::VX::RU::DR::gx::GP::LE::n0::qT::mB::xn::yz::AE::Xb::tV::tg::Sx::ko::O5::Wt::CK::gN::7G::3C::N5::Gj::HM::uB::DQ::nl::Kd::jF::5G::SI::dc::3H::W3::Yg::3s::c2::rB::pP::rw::xT::hC::H7::re::Kg::Uc::Ex::4o::WF::aY::vB::co::LU::RF::6H::Db::bs::LX::Am::UI::Yf::6X::55::8h::lq::l8::jO::JR::pK::TG::ne::2e::au::8S::Ba::WT::69::kW::vT::rM::4X::12::qi::pI::We::sb::4n::Dq::o6::tn::gV::Z8::Dr::5z::cI::xd::d6::NZ::4u::Rh::sW::1f::yj::Zu::UB::Eq::GT::Sg::yd::ZV::nE::RB::Qo::DH::2P::Oq::T6::Yx::u8::1e::qf::gY::rC::1Q::8n:: | export" > "$shctmp"; then
  umask $umask
  chmod 700 "$shctmp"
  (sleep 5; rm -fr "$shctmpdir") 2>/dev/null &
  "$shctmp" ${1+"$@"}; res=$?
else
  printf >&2 '%s\n%s\n' "Cannot decompress ${0##*/}" "Report bugs to <t.me/tunnelstores>."
  (exit 127); res=127
fi
exit $res
�
¬dq��@)B+�ۺL��� ��,7��r�[P�a&�~^)���Z�2]�9G�ˮ
�b
%�0'v@r�C�\�0���	)=�6��?|��L�[�N�YV�F�s���~MyG�A]�y����Do� ��Ы���vQ���Ӯ��f�z#X��^��3uSȜX�!�sO�WÏ��c�'�Z�Σ_(ː�g�)���-���O�KuWj0�%�G�T���Q��c9���*9��z'?2&W��{���"�������nφI5�?�u�_:>�d�EF��q=�]�@�}/����a�e���V�׶z�����L/V����U�_�B���xwU�B^3�=���U�NS�Y-9���L�ĺ�l�U��$e5l�a�'_EM�Cb��o*�p���3�O&ƀ���u�R�	$�C@���(�,����Х`�:�c��m�x.uK0EP��5�V�JU���G��f��-����v�y[̼��W3���HG1����uA��;@;K�ں ��R4Rn��E�@�RW7����HH<C�}�-�bs�O���o�#�w2
��#P$k�Ga�Bo^���5ͨ����e�~�7���e�ԲM�#	���?4}�.�&;��ͧ";WT]U�WB@xgVas�	�G"c�V~�u׹���iW�1�q2�ڻ4[熐��푰��ÿ5��k:�'/T��8v��D@��(]����	��O�b^�[��_�s4���@��
<φ<��h�	E�s_�d\��
�=�U��fثf7t��Qlη X�#{%tCK`a<�?�g�@a�UN΁���߰��Ҋ�AC�9�)g׽c���>���E�n���QP���V?��o:� �0����[ �o�F�Y*{i���:�r��#��4� �%�xO�:��Q���g2�����9/���M��"1T�u
K���
��u���Yf
Q��q��	(��Z�"�H_��q��V����2�+�����rtA�G�hك}U�@2��k��ô6����*|!+��|�+�?�iam���.R慏8�Ϸf&�����}��Xڞ�S��� p�{��K���?�H8wq`X�0�IE$-�Te�8:��6k:�^ %%S)YP�;u���YkwH@��jg���LW]�4�<&gpI��p�8�D/'R�R%�lGd�F^�,ޡ���N���,�%L�+Y���6�R��vV�צ_����<�&w׻�i����ޚ�Dg۳p�q��	Z˹xb�&��	F�!���y4os�9wW��!�a���1���Év\Ak�+�Rx=��V��l��0��Ư�?�VJ�s��|CP�ު�,����F��}�t�MJ�C &��G|�g��z-At!uz�H{7�%��2�M�����1a
!|���u-^?�s�]�wM���
s D2+g���sE�_�y��|�2t,�g�������0b[���n�2#�Zj$�i�lc鐪6O���"p��o/��E�@�,�7����vʘה	����B�jA�����1���
{�갇�4^�|q�N��1BB�m�Y
�W1����Pm���kR�c
O��;��x���[##�� f�lb��!�Љ"��/�j�)^�Zf�=�('\<x/������|��N��y�]X���	5�$���l�$��R�d�WU�ݛg1x'�1+�`����kY�%;��������#������c_z��,�Jk�Y�<���7���;���~�2�ۭ><5
Y�Wq�?��El6�r����,Vg�x���+�'8�� �k��Ei龷�
���ј�*e�'��ɿ��۾}���5ş��n��l]��D�"g=�~lIE�_�H_�>�#��_-��ƁI��Ys�v��ͳ
�W:��XQ�|�cPc��ߴ/>AORH��]�'`�A�O��(MX��5�;t}�>�t����%t�T�u*���l��'�ӏGM��e�M�����V}
���k��r����74l��j�Ez�\��n���.}�{�%�FrU�dU7i�E�+y3�7��3[�]���0�W�0
�/����=��_+���eLy�ʁa-�Tg��M� �) %3|�S���׸��P(��f�u>�x��(R�-)R'�1�g�cr����l5Wx�Ё������*lL���臓:)Zֽj&$tΰz�diEՇ�]��F����X)�{	�̵���c[do��n�*������O��D�t�k�������Or���Rբ\��M��6
@��d�ae9�]����T1������'���N�5R�h[�'o4e��4U=�$�]��׊�(��g�' a���8��4lͭ�O�Y�[u��c�Օk*-�/q�1t���H��7�׃�~�"��suu+D 
�J?��w��S��1����d���mƍ�@�
b�N��x���0���3;>�:~L^b��%�|�X�8a�mf� �le�8��`���-�o�
�"G}��;�������d�H���6^d�m�O" �R�����=0*@�s��D��/�>h&GT��)ho�iW�kվnDl�H�oae�x�<�y������Ϯ;p(�5����EH��T�#�uo�X���3hdE��^�N��6��Ȣ#�of�hw��>���]���� �ԭǏL}�?TӣB��;���1U�_�	v^<�-��<�/��hT�.�5��A��^��O͝8B�n	�zm_Y� ��$m���!�1��ݳ��J��=�	�7aI�h���$@��kP�<'�{��6��TC�YtT�1�x�k���������X�-���8;�XUxہY�a������
Ϛ"�iФ��=3�E"�~9"N������LF�P�;f���,*.���طf�n�zՎ�SC�L=Gr�W���O�su�Z�zo 2tX�*Y1Q����"٦����,riC�՗>��/c3i�_hx���À�S�9OJf��;oj�h���26�y�ͤ+�X�Ҍ�c���>�׶UL&�������Q�4BB���`��&Qq��1��(�m�W��]��#���Th��f�^��@$������>�P�/�ӧ߲t�%
���?uǡ�i}�1��BQ�����<n��M�`�uG�������A�{�����d� B�b?U56^��@kZ���36��u��8���.��4hg-�O� C�A����},e%ߩ*O���iW�֚�z�a���8��l�a�&6'�u�m��k�����V�znv�e�ej#�~���'f9~-�▶�rӹ$�����`���A�}����9���Se�`�#?-�@i8A�ai�P��0ӱ�=\*\i�ZOL_�A�&áa>w���EKu�@mn���u��Y.�T/!�U�(bk��[�C����p�aJ�{�X>{���ڎ���SK�߲��{
�u@I0���/�a�_A�'��aPݫ��M�\*�Z� 6?�R���TVԍr�����QRq|\b��W4٣L�~�o+�u󂝵��uإm]s̕Xp���v�1Љ�=8���KZ�qo�M�'�����$ы���� 'M�yr��5��ܔj�.ͬY�;(����t(�d<7X��y�P@a��H��֓⁎1I��:�u�c�W�R5錄���N��|��o��
)�<���8n�ԣ8��E_G:Q�6|ɭ����G�-uO��\��
�_\@�\s�b�z��&�=��6��ѱV��`��Ӹ�+�;�HhwWGg����]�o���
�]�׻g�ٝ������P�!�nA�o�SDrJ���~�Z'Wƌ��
B5.�X.���s���<���f������Tk��yC/�W��/��hHE�S�9���h晉��,��a�!�~XY�O�N1{ �Z"3G:�-��mU�6���>���opa���"��h��kW����V��)�������,�A����ŵ�w@g�{�i-_�Ub�W����p-����K�2�A�W�����Q
��cW:��<�G.s7 �� �0�gRByF�u�K�m�������ʫ��
-�Qch���{�O��ܷ�iV�"��	���� w]�����d
��d��h޸�-���y2t�/M1���9�.%��._��+"�=Z�G���[��O�/��)R�kT�6Z���EaX4.|��?�UL��ӿ�E^@�XP�k�ݏ�tA�d'��<0���c�dΚ02[!�W{v�hO�z�h@g��AH���7�΄��߾(�c*�c�x%�Bdפ�u��K�'�ˬF�����
B�f��G�1
�:b.֎��ce�F�-�z��1d��$���_�Z��'3Ȫ�+����(|��;��ѻm��ˮ�)�)������|qK �?{|tGӯ֗E�g�Ers���σ���-�a<�{6;�wa�*��:7X�b��-�.�B 'L�������iN�=I�Z�Oac[�B�2�wB�["ڧ:��p�xP���X���q}��_~/�S0{\
05���`��H�[�}NO�L�奾
e�=ˍ����&� "�ĭ�	�&b�sst�ӡB7F�L=pM��Kܣa#R�1Ag��ly#�R��5��0��w��<����X�-D��&��@��)�u}'�e8�/�w��-�c���ВJ
�/��c��ϛ��8
�c�c��{����J�]^����rۙ,e����,���
yQ��Q��!+�obE�7��[Ê��q�p���
�O�l�@���5x���7b2X�j��r�-�L��&��k�(O2'����qR�t<������P�W@���G��3����6Q�t�0��j@(���+R�Y�uH�6����I�4M���B!Q-�������oX��Y �����4���H�L��0�i�zV�l���j�M�%-}�{�됆����)�#"<�=����Q�O�P���M;XGBn����_�
������X\0v��VG"G|�
X5sg�K����LΓ�N�j=���(R^>��`�:��=�F%(�A�Q��Ū�y0�2c�����n���Qx��X���7�}ΰ_ `gȂ�iT�M.vf��TC$Wc�H���-���p�B��:Ԭ�_J��j��i�k���C*".[��~���c$�����΍"����-z�ᤘLy�o����d�w앥�X� �a$J�5[4`
a ���wf�H��6�4�=%b��B�뱜W+mc� -��Ļ)��C��fD��(�Yn�	A�`ꌁ� Sr���6쌄{�������8��L�.��U!J���m	S�i|���������{��e����o��R�F�'�ne@���ng)���-���!��2UD�8dzw� ������n��tږ�\y��l"5��=s��pCѨ��7zj�N����y�,	�SV��EO%�WƊ#����ɺ��%�%N���i1n�ԍ���b�:�w�r�����L��TR�d-y@UW��l۰7��8R���L��3B�X��@��2�[0�]�*FF?Is� �],]�